import { KOL } from "@/types/kol";
import { createClient } from '@supabase/supabase-js';
import { SUPABASE_URL, SUPABASE_ANON_KEY } from '@/config/supabase';

const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
  realtime: {
    params: {
      eventsPerSecond: 10
    }
  }
});

export async function fetchKOLs(): Promise<KOL[]> {
  try {
    const { data: timerState } = await supabase
      .from('timer_state')
      .select('round')
      .order('created_at', { ascending: false })
      .limit(1)
      .single();

    if (!timerState) return [];
    const currentRound = timerState.round;

    const { data, error } = await supabase
      .from('kols')
      .select(`
        *,
        round_downvotes:downvotes!inner(
          round,
          count,
          updated_at
        )
      `)
      .eq('downvotes.round', currentRound)
      .order('downvotes', { ascending: false });
    
    if (error) throw error;
    
    return data || [];
  } catch (error) {
    console.error("Error fetching KOLs:", error);
    return [];
  }
}

export async function downvoteKOL(id: string, currentDownvotes: number): Promise<boolean> {
  try {
    const { data: timerState } = await supabase
      .from('timer_state')
      .select('*')
      .order('created_at', { ascending: false })
      .limit(1)
      .single();

    if (!timerState) return false;

    const { error: voteError } = await supabase.rpc('increment_downvotes', {
      input_kol_id: id,
      input_round: timerState.round
    });

    if (voteError) {
      console.error("Error in downvoteKOL:", voteError);
      return false;
    }

    return true;
  } catch (error) {
    console.error("Error in downvoteKOL:", error);
    return false;
  }
}

export async function fetchCurrentVotes(round: number): Promise<Record<string, number>> {
  try {
    const { data, error } = await supabase
      .from('downvotes')
      .select('kol_id, count')
      .eq('round', round);
    
    if (error) throw error;
    
    return (data || []).reduce((acc, vote) => {
      acc[vote.kol_id] = vote.count;
      return acc;
    }, {} as Record<string, number>);
  } catch (error) {
    console.error("Error fetching votes:", error);
    return {};
  }
}

export function subscribeToVotes(round: number, callback: (votes: Record<string, number>) => void) {
  // Initial fetch
  fetchCurrentVotes(round).then(callback);

  // Subscribe to downvotes table changes
  const subscription = supabase
    .channel('downvotes_changes')
    .on('postgres_changes',
      {
        event: '*',
        schema: 'public',
        table: 'downvotes',
        filter: `round=eq.${round}`
      },
      async () => {
        const votes = await fetchCurrentVotes(round);
        callback(votes);
      }
    )
    .subscribe();

  return () => {
    subscription.unsubscribe();
  };
}

export function subscribeToKOLs(callback: (kols: KOL[]) => void) {
  // Initial fetch
  fetchKOLs().then(callback);

  // Subscribe to kols table changes
  const subscription = supabase
    .channel('kols_changes')
    .on('postgres_changes',
      {
        event: '*',
        schema: 'public',
        table: 'kols'
      },
      async () => {
        const kols = await fetchKOLs();
        callback(kols);
      }
    )
    .subscribe();

  return () => {
    subscription.unsubscribe();
  };
}

export async function getTimerState() {
  try {
    const { data, error } = await supabase
      .from('timer_state')
      .select('*')
      .order('created_at', { ascending: false })
      .limit(1)
      .maybeSingle();

    if (error) {
      console.error("Error fetching timer state:", error);
      return null;
    }

    if (!data) {
      const startTime = new Date();
      const { data: newData, error: createError } = await supabase
        .from('timer_state')
        .insert({
          start_time: startTime.toISOString(),
          round: 1
        })
        .select()
        .single();

      if (createError) {
        console.error("Error creating timer state:", createError);
        return null;
      }

      return newData;
    }

    return data;
  } catch (error) {
    console.error("Error in getTimerState:", error);
    return null;
  }
}

export async function updateTimerState(round: number) {
  try {
    const previousRound = round - 1;
    
    const { data: roundVotes } = await supabase
      .from('downvotes')
      .select('kol_id, count')
      .eq('round', previousRound)
      .order('count', { ascending: false })
      .limit(1)
      .maybeSingle();

    if (roundVotes && roundVotes.count >= 2) {
      const { data: kol } = await supabase
        .from('kols')
        .select('*')
        .eq('id', roundVotes.kol_id)
        .single();

      if (kol) {
        const { error: larpError } = await supabase
          .from('larps')
          .upsert({
            round: previousRound,
            kol_id: kol.id,
            twitter_handle: kol.twitter_handle,
            name: kol.name,
            profile_img: kol.profile_img,
            twitter_url: kol.twitter_url,
            reason: kol.reason,
            downvotes: kol.downvotes
          });

        if (larpError) {
          console.error("Error updating LARP:", larpError);
        }
      }
    }

    const { error } = await supabase
      .from('timer_state')
      .update({ round })
      .order('created_at', { ascending: false })
      .limit(1);

    if (error) {
      console.error("Error updating timer state:", error);
      return false;
    }

    return true;
  } catch (error) {
    console.error("Error updating timer state:", error);
    return false;
  }
}

export async function fetchCurrentLarp(round: number): Promise<KOL | null> {
  try {
    const { data: currentLarp } = await supabase
      .from('larps')
      .select('*')
      .eq('round', round)
      .maybeSingle();

    if (currentLarp) {
      return {
        id: currentLarp.kol_id,
        twitter_handle: currentLarp.twitter_handle,
        name: currentLarp.name,
        profile_img: currentLarp.profile_img,
        twitter_url: currentLarp.twitter_url,
        reason: currentLarp.reason,
        downvotes: currentLarp.downvotes,
        created_at: currentLarp.created_at
      };
    }

    return null;
  } catch (error) {
    console.error("Error in fetchCurrentLarp:", error);
    return null;
  }
}

export function subscribeToLarps(callback: (larp: KOL | null) => void) {
  const subscription = supabase
    .channel('larps_changes')
    .on('postgres_changes', 
      { 
        event: '*', 
        schema: 'public', 
        table: 'larps' 
      }, 
      async (payload) => {
        if (payload.new) {
          const larp = payload.new as any;
          callback({
            id: larp.kol_id,
            twitter_handle: larp.twitter_handle,
            name: larp.name,
            profile_img: larp.profile_img,
            twitter_url: larp.twitter_url,
            reason: larp.reason,
            downvotes: larp.downvotes,
            created_at: larp.created_at
          });
        } else if (payload.eventType === 'DELETE') {
          callback(null);
        }
      }
    )
    .subscribe();

  return () => {
    subscription.unsubscribe();
  };
}
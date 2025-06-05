import React, { useMemo } from "react";
import { KOL } from "@/types/kol";
import { KOLCard } from "./KOLCard";
import { motion } from "framer-motion";

interface KOLGridProps {
  kols: KOL[];
  onDownvote: (id: string) => void;
  cycleVotes: Record<string, number>;
}

export function KOLGrid({ kols, onDownvote, cycleVotes }: KOLGridProps) {
  // Create a stable sorted array based on creation time
  const stableKols = useMemo(() => {
    return [...kols].sort((a, b) => {
      const timeA = new Date(a.created_at || '').getTime();
      const timeB = new Date(b.created_at || '').getTime();
      return timeA - timeB;
    });
  }, [kols]);

  // Find the KOL with the most votes in this cycle
  const [topVotedId, topVotes] = useMemo(() => {
    return Object.entries(cycleVotes).reduce(
      (max, current) => (current[1] > max[1] ? current : max),
      ["", 0]
    );
  }, [cycleVotes]);

  if (stableKols.length === 0) {
    return (
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ duration: 0.5 }}
        className="text-center py-16 px-4 border-2 border-dashed border-gray-800 rounded-xl max-w-3xl mx-auto"
      >
        <h3 className="text-xl font-semibold text-gray-300 mb-2">No KOLs Added Yet</h3>
        <p className="text-gray-400">
          Be the first to add a FUD-spreading KOL to the list.
        </p>
      </motion.div>
    );
  }
  
  return (
    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 2xl:grid-cols-5 gap-6">
      {stableKols.map((kol) => (
        <div key={kol.id} className="transform-none">
          <KOLCard 
            kol={kol} 
            onDownvote={onDownvote} 
            isTopVoted={kol.id === topVotedId && topVotes > 0}
            cycleVotes={cycleVotes[kol.id] || 0}
          />
        </div>
      ))}
    </div>
  );
}
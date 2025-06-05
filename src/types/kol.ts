export interface KOL {
  id: string;
  twitter_handle: string;
  name: string;
  profile_img: string;
  twitter_url: string;
  reason?: string;
  downvotes: number;
  created_at?: string;
  round_downvotes?: Array<{
    round: number;
    count: number;
    updated_at: string;
  }>;
}

export interface KOLPreview {
  username: string;
  name: string;
  image: string;
  profileUrl: string;
}
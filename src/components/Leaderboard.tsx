import { KOL } from "@/types/kol";
import { motion } from "framer-motion";
import { Trophy } from "lucide-react";

interface LeaderboardProps {
  kols: KOL[];
}

export function Leaderboard({ kols }: LeaderboardProps) {
  // Sort KOLs by downvotes in descending order
  const topKols = [...kols]
    .sort((a, b) => b.downvotes - a.downvotes)
    .slice(0, 5); // Take top 5

  if (topKols.length === 0) return null;

  return (
    <div className="mt-20 max-w-4xl mx-auto">
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5 }}
        className="text-center mb-8"
      >
        <h2 className="text-6xl font-black text-white flex items-center justify-center gap-4">
          <Trophy className="h-12 w-12" />
          Most Hated KOLs
          <Trophy className="h-12 w-12" />
        </h2>
        <p className="text-gray-400 mt-2">The ultimate hall of shame. Updated in real-time.</p>
      </motion.div>

      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5 }}
        className="bg-gray-900/50 border border-gray-800 rounded-xl p-6"
      >
        <div className="space-y-4">
          {topKols.map((kol, index) => (
            <motion.div
              key={kol.id}
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ duration: 0.3, delay: index * 0.1 }}
              className={`flex items-center gap-4 p-4 rounded-lg ${
                index === 0 
                  ? 'bg-yellow-500/10 border border-yellow-500/20' 
                  : index === 1 
                    ? 'bg-gray-300/10 border border-gray-300/20'
                    : index === 2 
                      ? 'bg-orange-500/10 border border-orange-500/20'
                      : 'bg-gray-800/50 border border-gray-700'
              }`}
            >
              <div className={`w-8 h-8 flex items-center justify-center rounded-full text-lg font-bold ${
                index === 0 
                  ? 'bg-yellow-500 text-black' 
                  : index === 1 
                    ? 'bg-gray-300 text-black'
                    : index === 2 
                      ? 'bg-orange-500 text-black'
                      : 'bg-gray-700 text-white'
              }`}>
                {index + 1}
              </div>
              
              <div className="flex items-center gap-3 flex-1">
                <img
                  src={kol.profile_img}
                  alt={kol.name}
                  className="w-10 h-10 rounded-full object-cover border-2 border-gray-700"
                  onError={(e) => {
                    const target = e.target as HTMLImageElement;
                    target.src = "https://via.placeholder.com/40?text=?";
                  }}
                />
                <div>
                  <h3 className="font-semibold text-white">{kol.name}</h3>
                  <a
                    href={kol.twitter_url}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="text-sm text-blue-400 hover:text-blue-300 transition-colors"
                  >
                    @{kol.twitter_handle}
                  </a>
                </div>
              </div>
              
              <div className="flex items-center gap-2">
                <div className="px-3 py-1 rounded-full bg-red-500/20 border border-red-500/20">
                  <span className="text-red-400 font-semibold">-{kol.downvotes}</span>
                </div>
              </div>
            </motion.div>
          ))}
        </div>
      </motion.div>
    </div>
  );
}
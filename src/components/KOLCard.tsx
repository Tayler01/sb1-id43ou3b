import React from "react";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { ThumbsDown, Crown } from "lucide-react";
import { KOL } from "@/types/kol";
import { motion } from "framer-motion";

interface KOLCardProps {
  kol: KOL;
  onDownvote: (id: string) => void;
  isTopVoted: boolean;
  cycleVotes: number;
}

export function KOLCard({ kol, onDownvote, isTopVoted, cycleVotes }: KOLCardProps) {
  // Get current round's downvotes
  const currentRoundDownvotes = kol.round_downvotes?.[0]?.count || 0;

  return (
    <motion.div
      initial={{ opacity: 0, scale: 0.95 }}
      animate={{ opacity: 1, scale: 1 }}
      transition={{ duration: 0.3 }}
      whileHover={{ y: -5, transition: { duration: 0.2 } }}
    >
      <Card 
        className={`
          bg-black/40 backdrop-blur-sm border-gray-800 overflow-hidden h-full 
          ${isTopVoted ? 'ring-2 ring-red-500 border-red-500 shadow-lg shadow-red-500/20' : ''}
          transition-all duration-300
        `}
      >
        <CardContent className="p-4 flex flex-col h-full relative">
          {/* Glow effect */}
          <div className={`
            absolute inset-0 bg-gradient-to-b from-gray-800/5 to-transparent pointer-events-none
            ${isTopVoted ? 'animate-pulse' : ''}
          `} />
          
          <div className="flex items-center gap-3 mb-3 relative">
            <div className="relative">
              <div className={`absolute inset-0 rounded-full blur-md ${
                isTopVoted ? 'bg-red-500/20' : 'bg-blue-500/10'
              }`} />
              <img
                src={kol.profile_img}
                alt={kol.name}
                className={`w-16 h-16 rounded-full object-cover border-2 relative ${
                  isTopVoted ? 'border-red-500' : 'border-gray-800'
                }`}
                onError={(e) => {
                  const target = e.target as HTMLImageElement;
                  target.src = "https://via.placeholder.com/100?text=?";
                }}
              />
              <div className="absolute -bottom-1 -right-1 bg-black rounded-full p-0.5">
                <div className="bg-gray-800 rounded-full w-5 h-5 flex items-center justify-center">
                  <span className="text-xs text-white">𝕏</span>
                </div>
              </div>
              {isTopVoted && (
                <motion.div
                  initial={{ scale: 0 }}
                  animate={{ scale: 1 }}
                  className="absolute -top-2 -right-2 bg-red-500 rounded-full p-1"
                >
                  <Crown className="h-4 w-4 text-white" />
                </motion.div>
              )}
            </div>
            <div className="flex-1">
              <h3 className={`font-bold text-lg line-clamp-1 ${
                isTopVoted ? 'text-red-400' : 'text-white'
              }`}>{kol.name}</h3>
              <a
                href={kol.twitter_url}
                target="_blank"
                rel="noopener noreferrer"
                className={`text-sm line-clamp-1 ${
                  isTopVoted ? 'text-red-400 hover:text-red-300' : 'text-blue-400 hover:text-blue-300'
                }`}
              >
                @{kol.twitter_handle}
              </a>
            </div>
          </div>
          
          {kol.reason && (
            <div className={`
              bg-black/50 backdrop-blur-sm rounded-md p-3 mb-4 text-sm text-gray-300 flex-1 
              border ${isTopVoted ? 'border-red-500/20' : 'border-gray-800/50'}
            `}>
              <p className="line-clamp-3 italic">"{kol.reason}"</p>
            </div>
          )}
          
          <div className="mt-auto pt-2">
            <Button 
              variant="outline" 
              size="sm" 
              className={`
                w-full bg-black/50 backdrop-blur-sm transition-all duration-300 group
                ${isTopVoted 
                  ? 'border-red-500/30 hover:bg-red-950/30 hover:border-red-500' 
                  : 'border-gray-800 hover:bg-red-950/30 hover:border-red-500/30'}
              `}
              onClick={() => onDownvote(kol.id)}
            >
              <ThumbsDown className={`h-4 w-4 mr-2 ${
                isTopVoted ? 'text-red-400' : 'text-gray-400 group-hover:text-red-400'
              }`} />
              <span className={isTopVoted ? 'text-red-400' : 'text-gray-400 group-hover:text-red-400'}>
                Downvote
              </span>
              <div className="ml-auto flex items-center gap-2">
                {cycleVotes > 0 && (
                  <span className={`px-2 py-0.5 rounded-full text-xs ${
                    isTopVoted 
                      ? 'bg-red-500/20 text-red-300' 
                      : 'bg-blue-500/20 text-blue-300'
                  }`}>
                    +{cycleVotes}
                  </span>
                )}
                <span className="bg-black/50 backdrop-blur-sm px-2 py-0.5 rounded-full text-xs text-white border border-gray-800/50">
                  {currentRoundDownvotes}
                </span>
              </div>
            </Button>
          </div>
        </CardContent>
      </Card>
    </motion.div>
  );
}
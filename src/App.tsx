import { useEffect, useState } from 'react';
import { KOL } from './types/kol';
import { AddKOLDialog } from './components/AddKOLDialog';
import { KOLGrid } from './components/KOLGrid';
import { Leaderboard } from './components/Leaderboard';
import { fetchKOLs, downvoteKOL, fetchCurrentLarp, getTimerState, updateTimerState, subscribeToLarps, subscribeToKOLs, subscribeToVotes } from './services/kolService';
import { Twitter, Send, AlertTriangle, Crown, Copy, Check, Timer, RotateCcw } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import { Button } from './components/ui/button';
import { useToast } from './hooks/use-toast';
import { Progress } from './components/ui/progress';
import './App.css';

const ROUND_DURATION = 600; // 10 minutes in seconds
const MIN_VOTES_TO_CROWN = 2; // Minimum votes needed to become LARP of the Hill
const CONTRACT_ADDRESS = "0x000...000"; // Placeholder contract address

function App() {
  const [kols, setKols] = useState<KOL[]>([]);
  const [larp, setLarp] = useState<KOL | null>(null);
  const [cycleVotes, setCycleVotes] = useState<Record<string, number>>({});
  const [timeLeft, setTimeLeft] = useState(ROUND_DURATION);
  const [round, setRound] = useState(1);
  const [showRoundBanner, setShowRoundBanner] = useState(false);
  const [loading, setLoading] = useState(true);
  const [startTime, setStartTime] = useState<Date | null>(null);
  const [copied, setCopied] = useState(false);
  const { toast } = useToast();

  const getTimerClass = () => {
    const percentage = (timeLeft / ROUND_DURATION) * 100;
    if (percentage > 66) return 'timer-early';
    if (percentage > 33) return 'timer-mid';
    return 'timer-late';
  };

  const getProgressColor = () => {
    const percentage = (timeLeft / ROUND_DURATION) * 100;
    if (percentage > 66) return 'rgb(34, 197, 94)';
    if (percentage > 33) return 'rgb(234, 179, 8)';
    return 'rgb(239, 68, 68)';
  };

  const getProgressGlowColor = () => {
    const percentage = (timeLeft / ROUND_DURATION) * 100;
    if (percentage > 66) return 'rgba(34, 197, 94, 0.5)';
    if (percentage > 33) return 'rgba(234, 179, 8, 0.5)';
    return 'rgba(239, 68, 68, 0.5)';
  };

  const getTimerTextColor = () => {
    const percentage = (timeLeft / ROUND_DURATION) * 100;
    if (percentage > 66) return 'from-green-400 to-emerald-500';
    if (percentage > 33) return 'from-yellow-400 to-orange-500';
    return 'from-red-400 to-rose-500';
  };

  const getTimerBorderColor = () => {
    const percentage = (timeLeft / ROUND_DURATION) * 100;
    if (percentage > 66) return 'border-green-500/30';
    if (percentage > 33) return 'border-yellow-500/30';
    return 'border-red-500/30';
  };

  const getTimerGlowColor = () => {
    const percentage = (timeLeft / ROUND_DURATION) * 100;
    if (percentage > 66) return 'from-green-500 to-emerald-500';
    if (percentage > 33) return 'from-yellow-500 to-orange-500';
    return 'from-red-500 to-rose-500';
  };

  const loadKOLs = async () => {
    try {
      const kolsData = await fetchKOLs();
      setKols(kolsData);
    } catch (error) {
      console.error("Error loading KOLs:", error);
      toast({
        title: "Error",
        description: "Failed to load KOLs. Please try again.",
        variant: "destructive",
      });
    }
  };

  const handleCopyAddress = async () => {
    try {
      await navigator.clipboard.writeText(CONTRACT_ADDRESS);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
      toast({
        title: "Address copied!",
        description: "Contract address copied to clipboard",
      });
    } catch (err) {
      toast({
        title: "Failed to copy",
        description: "Please try copying manually",
        variant: "destructive",
      });
    }
  };

  useEffect(() => {
    const initializeApp = async () => {
      setLoading(true);
      try {
        const timerState = await getTimerState();
        if (timerState) {
          const start = new Date(timerState.start_time);
          setStartTime(start);
          const now = new Date();
          const secondsSinceStart = Math.floor((now.getTime() - start.getTime()) / 1000);
          const currentRound = Math.floor(secondsSinceStart / ROUND_DURATION) + 1;
          const timeLeftInCycle = ROUND_DURATION - (secondsSinceStart % ROUND_DURATION);
          
          setRound(currentRound);
          setTimeLeft(timeLeftInCycle);
          
          // Load KOLs and current LARP immediately
          const [kolsData, currentLarp] = await Promise.all([
            fetchKOLs(),
            fetchCurrentLarp(currentRound)
          ]);
          
          setKols(kolsData);
          setLarp(currentLarp);
        }
      } catch (error) {
        console.error("Error initializing app:", error);
      } finally {
        setLoading(false);
      }
    };

    initializeApp();

    // Set up real-time subscriptions
    const unsubscribeLarps = subscribeToLarps((newLarp) => {
      if (newLarp) {
        setLarp(newLarp);
        if (newLarp.name) {
          toast({
            title: "New LARP Crowned! 👑",
            description: `${newLarp.name} is the new LARP of the Hill!`,
          });
        }
      }
    });

    const unsubscribeKOLs = subscribeToKOLs((updatedKols) => {
      setKols(updatedKols);
    });

    const unsubscribeVotes = subscribeToVotes(round, (votes) => {
      setCycleVotes(votes);
    });

    return () => {
      unsubscribeLarps();
      unsubscribeKOLs();
      unsubscribeVotes();
    };
  }, []);

  useEffect(() => {
    if (!startTime) return;

    const updateTimer = async () => {
      const now = new Date();
      const secondsSinceStart = Math.floor((now.getTime() - startTime.getTime()) / 1000);
      const currentRound = Math.floor(secondsSinceStart / ROUND_DURATION) + 1;
      const timeLeftInCycle = ROUND_DURATION - (secondsSinceStart % ROUND_DURATION);

      if (timeLeftInCycle !== timeLeft) {
        setTimeLeft(timeLeftInCycle);
      }
      
      if (currentRound !== round) {
        setRound(currentRound);
        await updateTimerState(currentRound);
        setShowRoundBanner(true);
        setTimeout(() => setShowRoundBanner(false), 4000);
        setCycleVotes({});
        
        // Load new LARP when round changes
        const newLarp = await fetchCurrentLarp(currentRound);
        setLarp(newLarp);
      }
    };

    updateTimer();
    const interval = setInterval(updateTimer, 1000);
    return () => clearInterval(interval);
  }, [startTime, round, timeLeft]);

  async function handleDownvote(id: string) {
    const kol = kols.find((k) => k.id === id);
    if (!kol) return;
    
    const newVotes = (cycleVotes[id] || 0) + 1;
    setCycleVotes(prev => ({
      ...prev,
      [id]: newVotes
    }));

    setKols(prevKols => 
      prevKols.map(k => 
        k.id === id ? { ...k, downvotes: k.downvotes + 1 } : k
      )
    );

    const success = await downvoteKOL(id, kol.downvotes);
    
    if (!success) {
      setCycleVotes(prev => ({
        ...prev,
        [id]: Math.max(0, (prev[id] || 0) - 1)
      }));
      
      setKols(prevKols => 
        prevKols.map(k => 
          k.id === id ? { ...k, downvotes: k.downvotes - 1 } : k
        )
      );
    }
  }

  const progressValue = (timeLeft / ROUND_DURATION) * 100;
  const timerClass = getTimerClass();

  return (
    <div className="min-h-screen bg-gray-950">
      <div className="tech-grid"></div>
      <div className="circuit-lines"></div>

      <nav className="sticky top-0 z-50 bg-transparent backdrop-blur-sm border-b border-gray-800">
        <div className="max-w-[2000px] mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <motion.div
                initial={{ opacity: 0, x: -20 }}
                animate={{ opacity: 1, x: 0 }}
                className="flex items-center gap-2 bg-gray-900/50 rounded-lg px-3 py-2 border border-gray-800"
              >
                <span className="text-red-500 font-mono text-sm">Contract Adresse</span>
                <Button
                  variant="ghost"
                  size="icon"
                  className="h-6 w-6"
                  onClick={handleCopyAddress}
                >
                  {copied ? (
                    <Check className="h-4 w-4 text-green-500" />
                  ) : (
                    <Copy className="h-4 w-4 text-gray-400" />
                  )}
                </Button>
              </motion.div>
            </div>
            <div className="flex items-center gap-4">
              <a
                href="https://twitter.com/fudkol"
                target="_blank"
                rel="noopener noreferrer"
                className="text-gray-400 hover:text-blue-400 transition-colors"
              >
                <Twitter className="h-5 w-5" />
              </a>
              <a
                href="https://t.me/fudkol"
                target="_blank"
                rel="noopener noreferrer"
                className="text-gray-400 hover:text-blue-500 transition-colors"
              >
                <Send className="h-5 w-5" />
              </a>
              <AddKOLDialog onKOLAdded={loadKOLs} />
            </div>
          </div>
        </div>
      </nav>

      <main className="py-8 relative z-10">
        <div className="max-w-[2000px] mx-auto px-4 sm:px-6 lg:px-8">
          <div className="mb-12 text-center">
            <motion.div
              initial={{ y: -20, opacity: 0 }}
              animate={{ y: 0, opacity: 1 }}
              transition={{ duration: 0.5 }}
            >
              <h1 className="text-6xl sm:text-7xl md:text-8xl font-black text-white mb-6 bg-gradient-to-r from-red-500 via-orange-400 to-yellow-500 text-transparent bg-clip-text tracking-tight">
                FUDKOL
              </h1>
              <p className="text-gray-400 max-w-2xl mx-auto mb-8 text-lg">
                Your FUD Service Has Arrived.<br />
                You crown the LARP — we launch the raid. 🧻👎<br />
                Just drop the worst KOL. We'll handle the slander. Every 10 minutes, a new victim.
              </p>
            </motion.div>
          </div>

          <AnimatePresence>
            {larp && (
              <motion.div
                initial={{ opacity: 0, scale: 0.95 }}
                animate={{ opacity: 1, scale: 1 }}
                exit={{ opacity: 0, y: -20 }}
                transition={{ duration: 0.6 }}
                className="mb-8 max-w-4xl mx-auto"
              >
                <motion.div 
                  className="relative overflow-hidden rounded-xl bg-gradient-to-r from-red-900/50 via-black to-red-900/50 border border-red-500/50 p-8"
                  animate={{
                    boxShadow: [
                      "0 0 20px rgba(239, 68, 68, 0.3)",
                      "0 0 30px rgba(239, 68, 68, 0.3)",
                      "0 0 20px rgba(239, 68, 68, 0.3)"
                    ]
                  }}
                  transition={{
                    duration: 2,
                    repeat: Infinity,
                    repeatType: "reverse"
                  }}
                >
                  <div className="absolute inset-0 bg-grid-white/5" />
                  <motion.div
                    initial={{ opacity: 0 }}
                    animate={{ 
                      opacity: [0.7, 1, 0.7],
                      scale: [1, 1.05, 1],
                      x: [-5, 0, -5]
                    }}
                    transition={{
                      duration: 1.5,
                      repeat: Infinity,
                      repeatType: "reverse"
                    }}
                    className="absolute right-16 top-20"
                  >
                    <span className="text-red-400 font-bold tracking-[0.2em] text-3xl animate-pulse">
                      FUD ONGOING
                    </span>
                  </motion.div>
                  <div className="relative z-10">
                    <div className="flex items-center gap-6">
                      <motion.div 
                        className="relative flex-shrink-0"
                        animate={{
                          scale: [1, 1.05, 1],
                          rotate: [0, 2, -2, 0]
                        }}
                        transition={{
                          duration: 4,
                          repeat: Infinity,
                          repeatType: "reverse"
                        }}
                      >
                        <div className="absolute inset-0 bg-red-500/20 rounded-full blur-lg" />
                        <div className="relative">
                          <img 
                            src={larp.profile_img} 
                            alt={larp.name} 
                            className="w-32 h-32 rounded-full object-cover border-4 border-red-500/50 relative z-10"
                            onError={(e) => {
                              const target = e.target as HTMLImageElement;
                              target.src = "https://via.placeholder.com/128?text=?";
                            }}
                          />
                          <motion.div
                            className="absolute -top-3 -right-3 bg-red-500 rounded-full p-2"
                            animate={{
                              scale: [1, 1.2, 1],
                              rotate: [0, 10, -10, 0]
                            }}
                            transition={{
                              duration: 2,
                              repeat: Infinity
                            }}
                          >
                            <Crown className="h-6 w-6 text-white" />
                          </motion.div>
                        </div>
                      </motion.div>
                      <div className="flex-1">
                        <motion.div 
                          className="flex items-center gap-3 mb-2"
                          animate={{
                            x: [0, 2, -2, 0]
                          }}
                          transition={{
                            duration: 4,
                            repeat: Infinity
                          }}
                        >
                          <AlertTriangle className="h-7 w-7 text-red-500" />
                          <h2 className="text-3xl font-bold bg-gradient-to-r from-red-400 to-orange-400 text-transparent bg-clip-text">
                            LARP of the Hill
                          </h2>
                        </motion.div>
                        <p className="text-2xl font-semibold text-white mb-2">{larp.name}</p>
                        <div className="flex items-center gap-3">
                          <a
                            href={larp.twitter_url}
                            target="_blank"
                            rel="noopener noreferrer"
                            className="text-red-400 hover:text-red-300 transition-colors text-lg"
                          >
                            @{larp.twitter_handle}
                          </a>
                          <span className="text-gray-500">•</span>
                          <span className="text-lg text-gray-300 italic">"{larp.reason}"</span>
                        </div>
                      </div>
                    </div>
                  </div>
                </motion.div>
              </motion.div>
            )}
          </AnimatePresence>

          <div className="mb-12">
            <AnimatePresence>
              {showRoundBanner && (
                <motion.div
                  initial={{ opacity: 0, y: -20 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, y: 20 }}
                  className="text-center text-3xl font-extrabold text-white bg-gradient-to-r from-purple-600 via-purple-500 to-purple-600 p-4 rounded-xl shadow-xl mb-8 border border-purple-400/20"
                >
                  🥊 Round {round} — <span className="text-purple-200">Who's getting FUDded next on Twitter?</span>
                </motion.div>
              )}
            </AnimatePresence>

            <div className="text-center max-w-sm mx-auto">
              <div className="flex items-center justify-between mb-4">
                <motion.div
                  animate={{
                    scale: [1, 1.1, 1],
                    rotate: [0, 2, -2, 0]
                  }}
                  transition={{
                    duration: 2,
                    repeat: Infinity,
                    repeatType: "reverse"
                  }}
                  className="relative"
                >
                  <div className="absolute inset-0 bg-gradient-to-r from-blue-500 to-purple-500 rounded-lg blur-lg opacity-50"></div>
                  <div className="relative bg-gray-900 p-3 rounded-lg border border-blue-500/30">
                    <p className="text-blue-400 text-xs uppercase tracking-wider font-medium mb-1 flex items-center justify-center gap-1">
                      <RotateCcw className="w-3 h-3" /> Round
                    </p>
                    <p className="text-2xl font-black bg-gradient-to-r from-blue-400 to-purple-400 text-transparent bg-clip-text">
                      {round}
                    </p>
                  </div>
                </motion.div>

                <motion.div
                  animate={{
                    scale: timeLeft <= 10 ? [1, 1.2, 1] : 1,
                    color: timeLeft <= 10 ? ["#ffffff", "#ff4444", "#ffffff"] : "#ffffff"
                  }}
                  transition={{
                    duration: 0.5,
                    repeat: timeLeft <= 10 ? Infinity : 0,
                    repeatType: "reverse"
                  }}
                  className="relative"
                >
                  <div className={`absolute inset-0 bg-gradient-to-r ${getTimerGlowColor()} rounded-lg blur-lg opacity-50`}></div>
                  <div className={`relative bg-gray-900 p-3 rounded-lg border ${getTimerBorderColor()}`}>
                    <p className={`text-xs uppercase tracking-wider font-medium mb-1 flex items-center justify-center gap-1 bg-gradient-to-r ${getTimerTextColor()} text-transparent bg-clip-text`}>
                      <Timer className="w-3 h-3" /> Next Crown
                    </p>
                    <p className={`text-2xl font-black bg-gradient-to-r ${getTimerTextColor()} text-transparent bg-clip-text`}>
                      {Math.floor(timeLeft / 60)}:{String(timeLeft % 60).padStart(2, '0')}
                    </p>
                  </div>
                </motion.div>
              </div>

              <div className="relative h-3 rounded-full overflow-hidden progress-liquid-enhanced">
                <div 
                  className="absolute inset-0"
                  style={{ 
                    width: `${progressValue}%`,
                    background: getProgressColor(),
                    '--progress-glow-color': getProgressGlowColor()
                  } as React.CSSProperties}
                />
              </div>
            </div>
          </div>

          {loading ? (
            <div className="flex justify-center items-center py-20">
              <div className="animate-spin h-8 w-8 border-t-2 border-b-2 border-primary rounded-full"></div>
            </div>
          ) : (
            <>
              <KOLGrid kols={kols} onDownvote={handleDownvote} cycleVotes={cycleVotes} />
              <Leaderboard kols={kols} />
            </>
          )}
        </div>
      </main>

      <footer className="border-t border-gray-800 mt-20">
        <div className="max-w-[2000px] mx-auto px-4 sm:px-6 lg:px-8 py-6">
          <div className="flex flex-col sm:flex-row justify-between items-center gap-4">
            <div className="flex items-center gap-2">
              <span className="text-sm text-gray-400">
                © 2025 FUDKOL. All rights reserved.
              </span>
            </div>
            <div className="flex gap-6 text-sm">
              <a href="#" className="text-gray-400 hover:text-white transition-colors">Privacy</a>
              <a href="#" className="text-gray-400 hover:text-white transition-colors">Terms</a>
              <a href="#" className="text-gray-400 hover:text-white transition-colors">Contact</a>
            </div>
          </div>
        </div>
      </footer>
    </div>
  );
}

export default App;
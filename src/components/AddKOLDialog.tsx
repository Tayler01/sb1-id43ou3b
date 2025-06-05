import React, { useState } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog";
import { KOLPreview } from "@/types/kol";
import { supabase } from "@/config/supabase";
import { EDGE_FUNCTION_URL, SUPABASE_ANON_KEY } from "@/config/supabase";
import { Plus, Loader2, ExternalLink } from "lucide-react";
import { motion, AnimatePresence } from "framer-motion";

interface AddKOLDialogProps {
  onKOLAdded: () => void;
}

export function AddKOLDialog({ onKOLAdded }: AddKOLDialogProps) {
  const [twitterUrl, setTwitterUrl] = useState("");
  const [reason, setReason] = useState("");
  const [preview, setPreview] = useState<KOLPreview | null>(null);
  const [loading, setLoading] = useState(false);
  const [open, setOpen] = useState(false);

  async function handlePreview() {
    if (!twitterUrl.trim()) return;
    
    setLoading(true);
    try {
      const res = await fetch(EDGE_FUNCTION_URL, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${SUPABASE_ANON_KEY}`,
        },
        body: JSON.stringify({ twitterUrl }),
      });
      
      if (!res.ok) throw new Error("Failed to fetch preview");
      
      const data = await res.json();
      setPreview(data);
    } catch (error) {
      console.error("Error fetching preview:", error);
    } finally {
      setLoading(false);
    }
  }

  async function handleSubmit() {
    if (!preview || !reason.trim()) return;
    
    const { username, name, image, profileUrl } = preview;
    
    try {
      const { error } = await supabase
        .from('kols')
        .insert({
          twitter_handle: username,
          name,
          profile_img: image,
          twitter_url: profileUrl,
          reason,
          downvotes: 0,
        });

      if (error) throw error;
      
      setTwitterUrl("");
      setReason("");
      setPreview(null);
      setOpen(false);
      onKOLAdded();
    } catch (error) {
      console.error("Error adding KOL:", error);
    }
  }

  function resetForm() {
    setTwitterUrl("");
    setReason("");
    setPreview(null);
  }

  return (
    <Dialog open={open} onOpenChange={(newOpen) => {
      setOpen(newOpen);
      if (!newOpen) resetForm();
    }}>
      <DialogTrigger asChild>
        <div className="relative">
          <motion.div
            initial={{ opacity: 0.5 }}
            animate={{ 
              opacity: [0.5, 1, 0.5],
              scale: [1, 1.02, 1]
            }}
            transition={{
              duration: 2,
              repeat: Infinity,
              ease: "easeInOut"
            }}
            className="absolute inset-0 rounded-md bg-gray-500/50 blur-lg"
          />
          <Button 
            className="relative bg-gray-700 hover:bg-gray-600 text-white font-semibold px-6 py-3 rounded-md shadow-xl border border-gray-600/20 backdrop-blur-sm transition-all duration-300 hover:shadow-gray-500/20 gap-2"
          >
            <Plus className="h-5 w-5" />
            Add New KOL
          </Button>
        </div>
      </DialogTrigger>
      <DialogContent className="bg-gray-900 border border-gray-700 max-w-md">
        <DialogHeader>
          <DialogTitle className="text-xl font-bold bg-gradient-to-r from-blue-400 to-white text-transparent bg-clip-text">Add New KOL</DialogTitle>
        </DialogHeader>
        
        <div className="space-y-4 mt-4">
          <div>
            <label htmlFor="twitter-url" className="text-sm font-medium block mb-1.5 bg-gradient-to-r from-blue-400 to-white text-transparent bg-clip-text">
              Twitter Profile URL
            </label>
            <Input
              id="twitter-url"
              placeholder="https://twitter.com/username"
              value={twitterUrl}
              onChange={(e) => setTwitterUrl(e.target.value)}
              className="bg-gray-800 border-gray-700"
            />
          </div>
          
          <div>
            <label htmlFor="reason" className="text-sm font-medium block mb-1.5 flex justify-between">
              <span className="bg-gradient-to-r from-blue-400 to-white text-transparent bg-clip-text">Why is this person FUD-worthy?*</span>
              <span className="text-gray-400">({reason.length}/20)</span>
            </label>
            <Textarea
              id="reason"
              placeholder="Brief reason (required)"
              value={reason}
              onChange={(e) => setReason(e.target.value.slice(0, 20))}
              className="bg-gray-800 border-gray-700 min-h-[100px]"
              maxLength={20}
              required
            />
          </div>
          
          <Button 
            onClick={handlePreview} 
            disabled={loading || !twitterUrl.trim()} 
            className="w-full"
          >
            {loading ? (
              <>
                <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                Fetching...
              </>
            ) : (
              'Preview KOL'
            )}
          </Button>
          
          <AnimatePresence>
            {preview && (
              <motion.div
                initial={{ opacity: 0, height: 0 }}
                animate={{ opacity: 1, height: "auto" }}
                exit={{ opacity: 0, height: 0 }}
                transition={{ duration: 0.3 }}
                className="overflow-hidden"
              >
                <div className="border border-gray-700 rounded-md p-4 bg-gray-800/50">
                  <div className="flex items-center gap-3">
                    <img 
                      src={preview.image} 
                      alt={preview.name} 
                      className="w-16 h-16 rounded-full object-cover border-2 border-primary/20"
                      onError={(e) => {
                        const target = e.target as HTMLImageElement;
                        target.src = "https://via.placeholder.com/100?text=?";
                      }}
                    />
                    <div>
                      <h3 className="font-bold text-lg bg-gradient-to-r from-blue-400 to-white text-transparent bg-clip-text">{preview.name}</h3>
                      <a
                        href={preview.profileUrl}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="text-primary/80 hover:text-primary text-sm flex items-center gap-1"
                      >
                        @{preview.username}
                        <ExternalLink className="h-3 w-3" />
                      </a>
                    </div>
                  </div>
                  <Button 
                    className="w-full mt-4" 
                    onClick={handleSubmit}
                    variant="default"
                    disabled={!reason.trim()}
                  >
                    Add to FUDKOL List
                  </Button>
                </div>
              </motion.div>
            )}
          </AnimatePresence>
        </div>
      </DialogContent>
    </Dialog>
  );
}
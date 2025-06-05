const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization",
};

interface TwitterProfile {
  username: string;
  name: string;
  image: string;
  profileUrl: string;
}

Deno.serve(async (req: Request) => {
  // Handle CORS preflight requests
  if (req.method === "OPTIONS") {
    return new Response(null, {
      status: 200,
      headers: corsHeaders,
    });
  }

  try {
    const { twitterUrl } = await req.json();

    // Extract username from URL
    const username = twitterUrl.split("/").pop()?.split("?")[0];
    if (!username) {
      throw new Error("Invalid Twitter URL");
    }

    // For demo purposes, we'll return mock data
    // In production, you'd want to use Twitter's API
    const profile: TwitterProfile = {
      username,
      name: username.charAt(0).toUpperCase() + username.slice(1),
      image: `https://unavatar.io/twitter/${username}`,
      profileUrl: `https://twitter.com/${username}`,
    };

    return new Response(
      JSON.stringify(profile),
      {
        headers: {
          "Content-Type": "application/json",
          ...corsHeaders,
        },
      }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        status: 400,
        headers: {
          "Content-Type": "application/json",
          ...corsHeaders,
        },
      }
    );
  }
});
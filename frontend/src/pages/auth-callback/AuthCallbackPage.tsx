import { Card, CardContent } from "@/components/ui/card";
import { axiosInstance } from "@/lib/axios";
import { Loader } from "lucide-react";
import { useEffect, useRef } from "react";
import { useNavigate } from "react-router-dom";
import { useAuthStore } from "@/stores/useAuthStore";

const AuthCallbackPage = () => {
  const navigate = useNavigate();
  const callbackAttempted = useRef(false);
  const { checkAdminStatus } = useAuthStore();

  //This effect then calls processCallback() immediately. 
  // That function reads the OAuth code from the URL, sends it to the backend, checks the user, and navigates to /. 
  // If there’s no code or an error occurs, it navigates to /login.
  useEffect(() => {
    const processCallback = async () => {
      if (callbackAttempted.current) return;

      callbackAttempted.current = true;

      const code = new URLSearchParams(
        window.location.search
      ).get("code");

      if (!code) {
        console.error("No authorization code found");
        navigate("/login");
        return;
      }

      try {
        // making backend API call to pass code
        await axiosInstance.post("/auth/callback", {
          code,
        });

        // making backend API call to get user data and check if the user is an admin or not.
        await axiosInstance.get(
          "/auth/me",
          {
            withCredentials: true, // This is important to include cookies in the request
          }
        );
        

        // `/auth/me` retrieves "isAdmin" from backend 
        // but its value is discarded and rather we call checkAdminStatus(), 
        // which calls `/admin/check` to update the Zustand store with the admin status.
        // WHY???


        await checkAdminStatus();

        navigate("/");
      } catch (error) {
        console.error(
          "Error processing auth callback",
          error
        );

        navigate("/login");
      }
    };

    processCallback();
  }, [navigate]);

  return (
    <div className="h-screen w-full bg-black flex items-center justify-center">
      <Card className="w-[90%] max-w-md bg-zinc-900 border-zinc-800">
        <CardContent className="flex flex-col items-center gap-4 pt-6">
          <Loader className="size-6 text-emerald-500 animate-spin" />
          <h3 className="text-zinc-400 text-xl font-bold">
            Logging you in
          </h3>
          <p className="text-zinc-400 text-sm">
            Redirecting...
          </p>
        </CardContent>
      </Card>
    </div>
  );
};

export default AuthCallbackPage;



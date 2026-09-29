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
        // this call makes backend exchange code for access token from Cognito
        // and return user information like userid and email (which is not stored. WHY ???)
        // and cookie header. This cookie is stored directly by the browser when it receives the response
        // No frontend code required.

        await axiosInstance.post("/auth/callback", {
          code,
        });

        // making backend API call to get user data and check if the user is an admin or not.

        // `/auth/me` retrieves "isAdmin" from backend 
        // but its value is discarded and rather we call checkAdminStatus(), 
        // which calls `/admin/check` to update the Zustand store with the admin status.
        // WHY??? SHOULD BE REMOVED.

        await axiosInstance.get(
          "/auth/me",
          {
            // This is explicitly include cookies in the request as frontend and backend are on different domains. 
            // If backend and frontend were on the same domain, this would not be necessary.
            withCredentials: true,
          }
        );

        // This call updates the Zustand store with the admin status of the user.

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



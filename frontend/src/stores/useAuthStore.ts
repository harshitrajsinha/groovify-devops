import { axiosInstance } from "@/lib/axios";
import { create } from "zustand";

interface AuthStore {
	isAdmin: boolean;
	isLoading: boolean;
	error: string | null;
	isAuthenticated: boolean;

	initializeAuth: () => Promise<void>;
	checkAdminStatus: () => Promise<void>;
	logout: () => Promise<void>;
	reset: () => void;
}

export const useAuthStore = create<AuthStore>((set) => ({
	isAdmin: false,
	isLoading: false,
	error: null,
	isAuthenticated: false,

	checkAdminStatus: async () => {
		set({ isLoading: true, error: null });
		try {
			const response = await axiosInstance.get("/admin/check");
			set({ isAdmin: response.data.admin }); // it will always be true.
		} catch (error: any) {
			set({ isAdmin: false, error: error.response.data.message });
		} finally {
			set({ isLoading: false });
		}
	},
  
  // We directly check for admin status and decide the authentication state as well
  // because as of now the current flow only has admin users that can log in. 
  // So if the user is an admin, we can say that the user is authenticated as well or vice versa.
	initializeAuth: async () => {
    set({
      isLoading: true,
      error: null,
    });

    try {
      const response =
        await axiosInstance.get(
          "/admin/check"
        );

      set({
        isAuthenticated: true,
        isAdmin: response.data.admin, // it will always be true. 
      });
    } catch {
      set({
        // If the user's data does not exist in AWS Cognito or user does not have cookie saved, this section will be executed.
        isAuthenticated: false,
        isAdmin: false,
      });
    } finally {
      set({
        isLoading: false,
      });
    }
  },

	logout: async () => {
    try {
      const response =
        await axiosInstance.post(
          "/auth/logout"
        );

      set({
        isAuthenticated: false,
        isAdmin: false,
      });

      window.location.href =
        response.data.logoutUrl;
    } catch (error) {
      console.error(error);
    }
  },

	reset: () => {
		set({ isAdmin: false, isLoading: false, error: null });
	},
}));

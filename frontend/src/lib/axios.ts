import axios from "axios";

export const axiosInstance = axios.create({
	baseURL: window.__CONFIG__.VITE_MODE === "development" ? window.__CONFIG__.VITE_BACKEND_URL + "/api" : "/api",
	 withCredentials: true,
});

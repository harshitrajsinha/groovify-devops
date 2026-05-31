import axios from "axios";
import jwt from "jsonwebtoken";
import { User } from "../models/user.model.js";

export const authCallback = async (req, res, next) => {
	try {
		const { code } = req.body;

		if (!code) {
			return res.status(400).json({
				message: "Authorization code missing",
			});
		}

		const params = new URLSearchParams();

		params.append(
			"grant_type",
			"authorization_code"
		);

		params.append(
			"client_id",
			process.env.COGNITO_CLIENT_ID
		);

		params.append("code", code);

		params.append(
			"redirect_uri",
			process.env.COGNITO_REDIRECT_URI
		);

		const tokenResponse = await axios.post(
			`${process.env.COGNITO_DOMAIN}/oauth2/token`,
			params,
			{
				headers: {
					"Content-Type":
						"application/x-www-form-urlencoded",
				},
			}
		);

		const {
			id_token,
		} = tokenResponse.data;

		const claims = jwt.decode(id_token);

		// console.log(
		// 	"Cognito User Claims:",
		// 	claims
		// );

		let user = await User.findOne({
			authProviderId: claims.sub,
		});

		if (!user) {
			user = await User.create({
				authProviderId: claims.sub,
				fullName: `${claims.given_name || ""} ${
					claims.family_name || ""
				}`.trim(),
				imageUrl: claims.picture || "",
			});
		}

		res.cookie(
			"auth_token",
			id_token,
			{
				httpOnly: true,
				secure:
					process.env.NODE_ENV ===
					"production",
				sameSite: "lax",
				maxAge:
					24 *
					60 *
					60 *
					1000,
			}
		);

		res.status(200).json({
			success: true,
			userId: claims.sub,
			email: claims.email,
		});
	} catch (error) {
		console.log(
			"Auth callback error:",
			error.response?.data ||
				error.message
		);

		next(error);
	}
};
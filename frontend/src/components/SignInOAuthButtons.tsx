import { Button } from "./ui/button";

const SignInOAuthButtons = () => {
  const signInWithGoogle = () => {
    const domain = window.__CONFIG__.VITE_COGNITO_DOMAIN;
    const clientId = window.__CONFIG__.VITE_COGNITO_CLIENT_ID;
    const redirectUri = encodeURIComponent(
      `${window.location.origin}/auth-callback`
    );

    // user is redirected to this url when button is clicked. This url is the AWS Cognito hosted login page for Google OAuth.
    // `/auth-callback` is the route where the user will be redirected after successful login. This route is handled in App.tsx and AuthCallbackPage.tsx.
    const authUrl =
      `${domain}/oauth2/authorize` +
      `?identity_provider=Google` +
      `&response_type=code` +
      `&client_id=${clientId}` +
      `&redirect_uri=${redirectUri}` +
      `&scope=openid+email+profile`;

      // Makes the button click redirect to the AWS Cognito hosted login page for Google OAuth.
      window.location.href = authUrl;
  };

  return (
    // Button is rendered for "SignInOAuthButtons" component in Topbar.tsx
    <Button
      onClick={signInWithGoogle}
      variant="secondary"
      className="w-full text-white border-zinc-200 h-11"
    >
      <img src="/google.png" alt="Google" className="size-5" />
      Continue with Google
    </Button>
  );
};

export default SignInOAuthButtons;

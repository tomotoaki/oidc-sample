import { UserManager, WebStorageStateStore, User } from "oidc-client-ts";

const settings = {
    authority: import.meta.env.VITE_OIDC_AUTHORITY || "http://localhost:8082/realms/myrealm",
    client_id: import.meta.env.VITE_OIDC_CLIENT_ID || "exchange-client",
    client_secret: import.meta.env.VITE_OIDC_CLIENT_SECRET || "",
    redirect_uri: import.meta.env.VITE_OIDC_REDIRECT_URI || "http://127.0.0.1:8091/callback",
    post_logout_redirect_uri: "http://127.0.0.1:8091/",
    response_type: "code", // 認可コードフロー
    scope: "openid profile email",
    userStore: new WebStorageStateStore({ store: window.localStorage }),
};

export const userManager = new UserManager(settings);

// ログイン実行
export const login = (): Promise<void> => {
    return userManager.signinRedirect();
};

// ログアウト実行
export const logout = (): Promise<void> => {
    return userManager.signoutRedirect();
};

// コールバック処理 (state, nonce, PKCEの自動検証)
export const handleCallback = (): Promise<User> => {
    return userManager.signinRedirectCallback();
};

// 現在のユーザー情報を取得
export const getUser = (): Promise<User | null> => {
    return userManager.getUser();
};

// アクセストークンを取得
export const getAccessToken = async (): Promise<string | null> => {
    const user = await userManager.getUser();
    return user?.access_token || null;
};

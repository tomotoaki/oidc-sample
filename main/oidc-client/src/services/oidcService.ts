import { UserManager, WebStorageStateStore, User } from "oidc-client-ts";

const settings = {
    authority: import.meta.env.VITE_OIDC_AUTHORITY || "http://localhost:8082/realms/myrealm",
    client_id: import.meta.env.VITE_OIDC_CLIENT_ID || "oidc-client",
    client_secret: import.meta.env.VITE_OIDC_CLIENT_SECRET || "",
    redirect_uri: import.meta.env.VITE_OIDC_REDIRECT_URI || "http://localhost:8081/callback",
    post_logout_redirect_uri: "http://localhost:8081/",
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

// 強制的にローカルストレージをクリアしてログアウト
export const forceLogout = async (): Promise<void> => {
    // ローカルストレージのOIDC関連データを全てクリア
    await userManager.removeUser();
    localStorage.clear();
    // Keycloakのログアウトエンドポイントにリダイレクト
    window.location.href = "http://localhost:8082/realms/myrealm/protocol/openid-connect/logout?redirect_uri=" +
        encodeURIComponent("http://localhost:8081/");
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

// UserInfoエンドポイントを呼び出す
export const fetchUserInfo = async (): Promise<any> => {
    const user = await userManager.getUser();
    if (!user?.access_token) {
        throw new Error("アクセストークンがありません");
    }

    try {
        const metadata = await userManager.metadataService.getMetadata();
        const userInfoEndpoint = metadata.userinfo_endpoint;

        if (!userInfoEndpoint) {
            throw new Error("UserInfoエンドポイントが見つかりません");
        }

        const response = await fetch(userInfoEndpoint, {
            headers: {
                Authorization: `Bearer ${user.access_token}`,
            },
        });

        if (!response.ok) {
            throw new Error(`UserInfo取得失敗: ${response.statusText}`);
        }

        return await response.json();
    } catch (error) {
        console.error("UserInfo fetch error:", error);
        throw error;
    }
};

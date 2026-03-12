const EXCHANGE_SERVER_URL = "http://127.0.0.1:8090";

/**
 * Token Exchangeを実行する
 * mainドメインで取得したトークン（Token A）をexchange-server用のトークン（Token B）に交換する
 */
export const exchangeToken = async (mainToken: string): Promise<any> => {
    if (!mainToken) {
        throw new Error("メイントークンがありません");
    }

    try {
        const response = await fetch(`${EXCHANGE_SERVER_URL}/api/exchange`, {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
            },
            body: JSON.stringify({ token: mainToken }),
        });

        const responseText = await response.text();

        if (!response.ok) {
            let errorMessage = `Token exchange failed: ${response.status} ${response.statusText}`;
            try {
                const errorData = JSON.parse(responseText);
                if (errorData.message) {
                    errorMessage += ` - ${errorData.message}`;
                }
            } catch {
                if (responseText) {
                    errorMessage += ` - ${responseText.substring(0, 200)}`;
                }
            }
            throw new Error(errorMessage);
        }

        if (!responseText) {
            throw new Error("Empty response from server");
        }

        try {
            return JSON.parse(responseText);
        } catch (e) {
            throw new Error(`Invalid JSON response: ${responseText.substring(0, 100)}`);
        }
    } catch (error) {
        if (error instanceof Error) {
            throw error;
        }
        throw new Error("Token exchange failed: " + String(error));
    }
};

/**
 * 交換されたトークン（Token B）を使ってexchange-serverの保護されたAPIを呼び出す
 */
export const callProtectedApi = async (exchangedToken: string): Promise<any> => {
    if (!exchangedToken) {
        throw new Error("交換されたトークンがありません");
    }

    const response = await fetch(`${EXCHANGE_SERVER_URL}/api/protected/info`, {
        method: "GET",
        headers: {
            "Authorization": `Bearer ${exchangedToken}`,
        },
    });

    if (!response.ok) {
        const error = await response.text();
        throw new Error(`API call failed: ${error}`);
    }

    return await response.json();
};

/**
 * exchange-serverのpublicエンドポイントを呼び出す
 */
export const getPublicData = async (): Promise<any> => {
    const response = await fetch(`${EXCHANGE_SERVER_URL}/api/public`);
    if (!response.ok) {
        throw new Error("Failed to fetch public data");
    }
    return await response.json();
};

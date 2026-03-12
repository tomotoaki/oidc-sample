import { getAccessToken } from './oidcService';

// バックエンドAPIのベースURL
const API_BASE_URL = 'http://localhost:8080';

/**
 * APIリクエストのヘルパー関数
 */
async function apiRequest<T>(
  endpoint: string,
  options: RequestInit = {}
): Promise<T> {
  const url = `${API_BASE_URL}${endpoint}`;

  try {
    const response = await fetch(url, {
      ...options,
      headers: {
        'Content-Type': 'application/json',
        ...options.headers,
      },
    });

    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(`HTTP ${response.status}: ${errorText || response.statusText}`);
    }

    return await response.json();
  } catch (error) {
    console.error(`API request failed for ${endpoint}:`, error);
    throw error;
  }
}

/**
 * 認証が必要なAPIリクエストのヘルパー関数
 */
async function authenticatedRequest<T>(
  endpoint: string,
  options: RequestInit = {}
): Promise<T> {
  const token = await getAccessToken();

  if (!token) {
    throw new Error('アクセストークンが見つかりません。ログインしてください。');
  }

  return apiRequest<T>(endpoint, {
    ...options,
    headers: {
      Authorization: `Bearer ${token}`,
      ...options.headers,
    },
  });
}

// ==================== 公開API（認証不要） ====================

/**
 * 公開ヘルスチェックエンドポイント
 */
export async function getPublicHello(): Promise<{ message: string; timestamp: string }> {
  return apiRequest('/api/public/hello');
}

// ==================== 保護されたAPI（認証必要） ====================

/**
 * ユーザー情報を取得
 */
export async function getProtectedUser(): Promise<{
  message: string;
  username: string;
  email: string;
  subject: string;
  claims: Record<string, any>;
}> {
  return authenticatedRequest('/api/protected/user');
}

/**
 * ダッシュボードデータを取得
 */
export async function getProtectedDashboard(): Promise<{
  user: string;
  data: {
    tasks: number;
    messages: number;
    notifications: number;
  };
}> {
  return authenticatedRequest('/api/protected/dashboard');
}

// ==================== 汎用API呼び出し ====================

/**
 * カスタムエンドポイントへのGETリクエスト（認証必要）
 */
export async function getAuthenticated<T>(endpoint: string): Promise<T> {
  return authenticatedRequest<T>(endpoint);
}

/**
 * カスタムエンドポイントへのPOSTリクエスト（認証必要）
 */
export async function postAuthenticated<T>(
  endpoint: string,
  data: any
): Promise<T> {
  return authenticatedRequest<T>(endpoint, {
    method: 'POST',
    body: JSON.stringify(data),
  });
}

/**
 * カスタムエンドポイントへのPUTリクエスト（認証必要）
 */
export async function putAuthenticated<T>(
  endpoint: string,
  data: any
): Promise<T> {
  return authenticatedRequest<T>(endpoint, {
    method: 'PUT',
    body: JSON.stringify(data),
  });
}

/**
 * カスタムエンドポイントへのDELETEリクエスト（認証必要）
 */
export async function deleteAuthenticated<T>(endpoint: string): Promise<T> {
  return authenticatedRequest<T>(endpoint, {
    method: 'DELETE',
  });
}

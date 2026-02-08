import { UserManager, WebStorageStateStore, type UserManagerSettings } from 'oidc-client-ts'

const settings: UserManagerSettings = {
    authority: 'http://localhost:8082/realms/myrealm',
    client_id: 'vue-client',
    redirect_uri: 'http://localhost:8081/callback',
    response_type: 'code',
    scope: 'openid profile email',
    userStore: new WebStorageStateStore({ store: window.localStorage }),
}

export const userManager = new UserManager(settings)

export const login = () => userManager.signinRedirect()

export const logout = () => userManager.signoutRedirect()

export const handleCallback = () => userManager.signinRedirectCallback()

export const getUser = () => userManager.getUser()

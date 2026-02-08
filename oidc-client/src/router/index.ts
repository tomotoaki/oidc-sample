import { createRouter, createWebHistory } from 'vue-router';
import Home from '../views/Home.vue';
import Callback from '../views/Callback.vue';
import Dashboard from '../views/Dashboard.vue';

const router = createRouter({
    history: createWebHistory(),
    routes: [
        {
            path: '/',
            name: 'Home',
            component: Home,
        },
        {
            path: '/callback',
            name: 'Callback',
            component: Callback,
        },
        {
            path: '/dashboard',
            name: 'Dashboard',
            component: Dashboard,
        },
    ],
});

export default router;

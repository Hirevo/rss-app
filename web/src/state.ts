import type { Feed, Article } from "./types";

export type TokenData = {
    token: string,
};

export type ProfileData = {
    name: string,
    email: string,
    usingGoogle: string,
};

export class AppState {
    tokenData?: TokenData = undefined;
    profileData?: ProfileData = undefined;

    static endpoint = "API_ORIGIN";

    get loggedIn(): boolean {
        return this.profileData != undefined;
    }

    ready: Promise<void>;
    private setReady: () => void;

    constructor() {
        this.ready = new Promise((resolve) => {
            this.setReady = resolve;
        });
    }

    async loginFromToken(token: string) {
        await this.refreshProfileData({ token });
    }

    private async refreshProfileData(tokenData: TokenData) {
        this.profileData = undefined;
        this.tokenData = undefined;

        const url = `${AppState.endpoint}/api/v1/account/me`;

        const headers = new Headers();
        headers.append("Authorization", `Bearer ${tokenData.token}`);
        const requestOptions: RequestInit = {
            headers,
            method: "GET",
            mode: "cors",
        };
        const response = await fetch(url, requestOptions);

        if (response.status != 200) {
            throw new Error(`invalid status (url: '${url}')`);
        }

        const data = await response.json();

        const profileData: ProfileData = {
            name: data.name,
            email: data.email,
            usingGoogle: data.using_google,
        };

        this.tokenData = tokenData;
        this.profileData = profileData;

        localStorage.setItem("token", tokenData.token);

        this.setReady();

        return profileData;
    }

    async login(email: String, password: String) {
        this.profileData = undefined
        this.tokenData = undefined

        const url = `${AppState.endpoint}/auth/login`;

        const headers = new Headers();
        headers.append("Content-Type", "application/json");
        const requestOptions: RequestInit = {
            headers,
            method: "POST",
            mode: "cors",
            body: JSON.stringify({
                email,
                password,
            }),
        };
        const response = await fetch(url, requestOptions);

        if (response.status != 200) {
            throw new Error(`invalid status (url: '${url}')`);
        }

        const data = await response.json();

        const tokenData: TokenData = {
            token: data.token,
        };

        return await this.refreshProfileData(tokenData);
    }

    async register(email: String, name: string, password: String) {
        this.profileData = undefined
        this.tokenData = undefined

        const url = `${AppState.endpoint}/auth/register`;

        const headers = new Headers();
        headers.append("Content-Type", "application/json");
        const requestOptions: RequestInit = {
            headers,
            method: "POST",
            mode: "cors",
            body: JSON.stringify({
                email,
                name,
                password,
            }),
        };
        const response = await fetch(url, requestOptions);

        if (response.status != 200) {
            throw new Error(`invalid status (url: '${url}')`);
        }

        const data = await response.json();

        const tokenData: TokenData = {
            token: data.token,
        };

        return await this.refreshProfileData(tokenData);
    }

    async logout() {
        if (this.tokenData == undefined) return;

        const url = `${AppState.endpoint}/auth/logout`;

        const headers = new Headers();
        headers.append("Authorization", `Bearer ${this.tokenData?.token}`);
        const requestOptions: RequestInit = {
            headers,
            method: "POST",
            mode: "cors",
        };
        const response = await fetch(url, requestOptions);

        if (response.status != 200) {
            throw new Error(`invalid status (url: '${url}')`);
        }

        this.tokenData = undefined;
        this.profileData = undefined;

        return;
    }

    async feeds(): Promise<Feed[]> {
        const url = `${AppState.endpoint}/api/v1/feeds`;

        const headers = new Headers();
        headers.append("Authorization", `Bearer ${this.tokenData?.token}`);
        const requestOptions: RequestInit = {
            headers,
            method: "GET",
            mode: "cors",
        };
        const response = await fetch(url, requestOptions);

        if (response.status != 200) {
            throw new Error(`invalid status (url: '${url}')`);
        }

        const data = await response.json();

        return data.map(deserializeFeed);
    }

    async category(category: string): Promise<Feed[]> {
        const url = `${AppState.endpoint}/api/v1/category/${encodeURIComponent(category)}`;

        const headers = new Headers();
        headers.append("Authorization", `Bearer ${this.tokenData?.token}`);
        const requestOptions: RequestInit = {
            headers,
            method: "GET",
            mode: "cors",
        };
        const response = await fetch(url, requestOptions);

        if (response.status != 200) {
            throw new Error(`invalid status (url: '${url}')`);
        }

        const data = await response.json();

        return data.map(deserializeFeed);
    }

    async articles(feedId: string): Promise<Article[]> {
        const url = `${AppState.endpoint}/api/v1/articles/${encodeURIComponent(feedId)}`;

        const headers = new Headers();
        headers.append("Authorization", `Bearer ${this.tokenData?.token}`);
        const requestOptions: RequestInit = {
            headers,
            method: "GET",
            mode: "cors",
        };
        const response = await fetch(url, requestOptions);

        if (response.status != 200) {
            throw new Error(`invalid status (url: '${url}')`);
        }

        const data = await response.json();

        return data.map(deserializeArticle);
    }


    async article(articleId: string): Promise<Article> {
        const url = `${AppState.endpoint}/api/v1/article/${encodeURIComponent(articleId)}`;

        const headers = new Headers();
        headers.append("Authorization", `Bearer ${this.tokenData?.token}`);
        const requestOptions: RequestInit = {
            headers,
            method: "GET",
            mode: "cors",
        };
        const response = await fetch(url, requestOptions);

        if (response.status != 200) {
            throw new Error(`invalid status (url: '${url}')`);
        }

        const data = await response.json();

        return deserializeArticle(data);
    }

    async addFeed(feedUrl: string): Promise<void> {
        const url = `${AppState.endpoint}/api/v1/feeds`;

        const headers = new Headers();
        headers.append("Authorization", `Bearer ${this.tokenData?.token}`);
        headers.append("Content-Type", "application/json");
        const requestOptions: RequestInit = {
            headers,
            method: "PUT",
            mode: "cors",
            body: JSON.stringify({
                url: feedUrl,
            }),
        };
        const response = await fetch(url, requestOptions);

        if (response.status != 200) {
            throw new Error(`invalid status (url: '${url}')`);
        }

        return;
    }

    async deleteFeed(feedId: string): Promise<void> {
        const url = `${AppState.endpoint}/api/v1/feed/${encodeURIComponent(feedId)}`;

        const headers = new Headers();
        headers.append("Authorization", `Bearer ${this.tokenData?.token}`);
        const requestOptions: RequestInit = {
            headers,
            method: "DELETE",
            mode: "cors",
        };
        const response = await fetch(url, requestOptions);

        if (response.status != 200) {
            throw new Error(`invalid status (url: '${url}')`);
        }

        return;
    }

    async categories(): Promise<{ [key: string]: Feed[] }> {
        const url = `${AppState.endpoint}/api/v1/categories`;

        const headers = new Headers();
        headers.append("Authorization", `Bearer ${this.tokenData?.token}`);
        const requestOptions: RequestInit = {
            headers,
            method: "GET",
            mode: "cors",
        };
        const response = await fetch(url, requestOptions);

        if (response.status != 200) {
            throw new Error(`invalid status (url: '${url}')`);
        }

        const data = await response.json();

        return Object.entries(data)
            .map(([key, val]: [any, any]) => [key, val.map(deserializeFeed)])
            .reduce((acc, [key, val]) => ({ ...acc, [key]: val }), {});
    }

    async markAsRead(articleId: string, value: boolean = true): Promise<void> {
        const url = `${AppState.endpoint}/api/v1/article/${encodeURIComponent(articleId)}`;

        const headers = new Headers();
        headers.append("Authorization", `Bearer ${this.tokenData?.token}`);
        headers.append("Content-Type", "application/json");
        const requestOptions: RequestInit = {
            headers,
            method: "POST",
            mode: "cors",
            body: JSON.stringify({
                read: value,
            }),
        };
        const response = await fetch(url, requestOptions);

        if (response.status != 200) {
            throw new Error(`invalid status (url: '${url}')`);
        }

        return;
    }
}

function deserializeFeed(data: any): Feed {
    return {
        id: data.id,
        title: data.title,
        description: data.description,
        feedUrl: data.feed_url,
        homepageUrl: data.homepage_url,
    };
}

function deserializeArticle(data: any): Article {
    return {
        id: data.id,
        feedId: data.feed_id,
        title: data.title,
        url: data.url,
        htmlContent: data.html_content,
        markedAsRead: data.marked_as_read,
    };
}

export const state = new AppState();

export default state;

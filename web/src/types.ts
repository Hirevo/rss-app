
export type Feed = {
    id: string,
    title: string,
    description?: string,
    feedUrl?: string,
    homepageUrl?: string,
}

export type Article = {
    id: string,
    feedId: string,
    title: string,
    url?: string,
    htmlContent?: string,
    markedAsRead: boolean,
}

export type Category = {
    id: string,
}

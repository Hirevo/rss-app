table! {
    articles (id) {
        id -> Varchar,
        feed_id -> Varchar,
        title -> Varchar,
        url -> Nullable<Text>,
        html_content -> Nullable<Text>,
    }
}

table! {
    articles_read (user_id, article_id) {
        user_id -> Varchar,
        article_id -> Varchar,
    }
}

table! {
    feeds (id) {
        id -> Varchar,
        title -> Text,
        description -> Nullable<Text>,
        feed_url -> Nullable<Text>,
        homepage_url -> Nullable<Text>,
    }
}

table! {
    feed_categories (feed_id) {
        feed_id -> Varchar,
        category_name -> Varchar,
    }
}

table! {
    subscriptions (user_id, feed_id) {
        user_id -> Varchar,
        feed_id -> Varchar,
    }
}

table! {
    users (id) {
        id -> Varchar,
        email -> Varchar,
        google_uid -> Nullable<Varchar>,
        name -> Varchar,
        passwd -> Nullable<Varchar>,
    }
}

table! {
    salts (user_id) {
        user_id -> Varchar,
        salt -> Varchar,
    }
}

table! {
    tokens (token) {
        token -> Varchar,
        user_id -> Varchar,
        expiry -> Varchar,
    }
}

table! {
    sessions (id) {
        id -> Varchar,
        expiry -> Varchar,
        data -> Varchar,
    }
}

joinable!(articles -> feeds (feed_id));
joinable!(articles_read -> articles (article_id));
joinable!(articles_read -> users (user_id));
joinable!(feed_categories -> feeds (feed_id));
joinable!(salts -> users (user_id));
joinable!(tokens -> users (user_id));
joinable!(subscriptions -> feeds (feed_id));
joinable!(subscriptions -> users (user_id));

allow_tables_to_appear_in_same_query!(
    articles,
    articles_read,
    feeds,
    feed_categories,
    salts,
    tokens,
    subscriptions,
    users,
    sessions,
);

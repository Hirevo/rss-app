use serde::{Deserialize, Serialize};

use crate::db::schema::*;

#[derive(
    Debug,
    Clone,
    PartialEq,
    Serialize,
    Deserialize,
    Queryable,
    Insertable,
    Identifiable,
    AsChangeset,
)]
#[table_name = "users"]
#[primary_key(id)]
/// Represents a complete user entry, as stored in the database.
pub struct User {
    /// The user's ID.
    pub id: String,
    /// The user's email address.
    pub email: String,
    /// The user's Google user ID.
    pub google_uid: Option<String>,
    /// The user's displayable name.
    pub name: String,
    /// The user's SHA512-hashed password.
    pub passwd: Option<String>,
}

#[derive(
    Debug,
    Clone,
    PartialEq,
    Serialize,
    Deserialize,
    Queryable,
    Insertable,
    Identifiable,
    Associations,
    AsChangeset,
)]
#[table_name = "salts"]
#[belongs_to(User)]
#[primary_key(user_id)]
/// Represents a salt in the database.
pub struct Salt {
    /// The salt's related author ID.
    pub user_id: String,
    /// The salt itself.
    pub salt: String,
}

#[derive(
    Debug,
    Clone,
    PartialEq,
    Serialize,
    Deserialize,
    Queryable,
    Insertable,
    Identifiable,
    Associations,
    AsChangeset,
)]
#[table_name = "sessions"]
#[belongs_to(User)]
#[primary_key(id)]
/// Represents a session in the database.
pub struct Session {
    /// The session's ID.
    pub id: String,
    /// The session's related author ID.
    pub user_id: Option<String>,
    /// The session's expiry date.
    pub expiry: String,
    /// The session's associated data.
    pub data: String,
}

#[derive(
    Debug,
    Clone,
    PartialEq,
    Serialize,
    Deserialize,
    Queryable,
    Insertable,
    Identifiable,
    Associations,
    AsChangeset,
)]
#[table_name = "articles"]
#[belongs_to(Feed)]
#[primary_key(id)]
pub struct Article {
    pub id: String,
    pub feed_id: String,
    pub title: String,
    pub url: Option<String>,
    pub html_content: Option<String>,
}

#[derive(
    Debug,
    Clone,
    PartialEq,
    Serialize,
    Deserialize,
    Queryable,
    Insertable,
    Identifiable,
    Associations,
)]
#[table_name = "articles_read"]
#[belongs_to(User)]
#[belongs_to(Article)]
#[primary_key(user_id, article_id)]
pub struct ArticleRead {
    pub user_id: String,
    pub article_id: String,
}

#[derive(
    Debug,
    Clone,
    PartialEq,
    Serialize,
    Deserialize,
    Queryable,
    Insertable,
    Identifiable,
    Associations,
    AsChangeset,
)]
#[table_name = "feeds"]
#[primary_key(id)]
pub struct Feed {
    pub id: String,
    pub title: String,
    pub description: Option<String>,
    pub feed_url: Option<String>,
    pub homepage_url: Option<String>,
}

#[derive(
    Debug,
    Clone,
    PartialEq,
    Serialize,
    Deserialize,
    Queryable,
    Insertable,
    Identifiable,
    Associations,
)]
#[table_name = "feed_categories"]
#[belongs_to(Feed)]
#[primary_key(feed_id, category_name)]
pub struct FeedCategory {
    pub feed_id: String,
    pub category_name: String,
}

#[derive(
    Debug,
    Clone,
    PartialEq,
    Serialize,
    Deserialize,
    Queryable,
    Insertable,
    Identifiable,
    Associations,
)]
#[table_name = "subscriptions"]
#[belongs_to(User)]
#[belongs_to(Feed)]
#[primary_key(user_id, feed_id)]
pub struct Subscription {
    pub user_id: String,
    pub feed_id: String,
}

use serde::{Deserialize, Serialize};

pub mod account;
pub mod article;
pub mod articles;
pub mod categories;
pub mod feed;
pub mod feeds;

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct ArticleWithReadMarker {
    pub id: String,
    pub feed_id: String,
    pub title: String,
    pub url: Option<String>,
    pub html_content: Option<String>,
    pub marked_as_read: bool,
}

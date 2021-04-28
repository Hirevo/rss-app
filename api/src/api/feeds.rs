use std::ops::Deref;

use diesel::dsl as sql;
use diesel::prelude::*;
use serde::{Deserialize, Serialize};
use tide::{Request, Response, StatusCode};

use crate::db::models::{Article, Feed, FeedCategory, Subscription};
use crate::db::schema::*;
use crate::utils;
use crate::utils::auth::AuthExt;
use crate::State;

pub async fn get(req: Request<State>) -> tide::Result {
    let user = match req.get_user() {
        Some(user) => user,
        None => {
            return Ok(utils::response::error(
                StatusCode::Unauthorized,
                "you are not currently logged in",
            ));
        }
    };

    let feeds: Vec<Feed> = req
        .state()
        .repo
        .run({
            let user_id = user.id.clone();
            move |conn| {
                feeds::table
                    .inner_join(subscriptions::table)
                    .select(feeds::all_columns)
                    .filter(subscriptions::user_id.eq(user_id))
                    .load(conn)
            }
        })
        .await?;

    Ok(utils::response::json(&feeds))
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct RequestBody {
    pub url: String,
}

pub async fn put(mut req: Request<State>) -> tide::Result {
    let user = match req.get_user() {
        Some(user) => user,
        None => {
            return Ok(utils::response::error(
                StatusCode::Unauthorized,
                "you are not currently logged in",
            ));
        }
    };

    let body: RequestBody = req.body_json().await?;

    let response = req.state().http_client.get(&body.url).send().await?;
    let response = response.error_for_status()?;
    let text_body = response.text().await?;

    let parsed = feed_rs::parser::parse_with_uri(text_body.as_bytes(), Some(&body.url))?;

    let feed_id = utils::generate_id_from_data(parsed.id.as_bytes());
    let feed = Feed {
        id: feed_id.clone(),
        title: parsed
            .title
            .as_ref()
            .map(|it| it.content.clone())
            .unwrap_or_else(|| parsed.id.clone()),
        description: parsed.description.as_ref().map(|it| it.content.clone()),
        feed_url: Some(body.url.clone()),
        homepage_url: None,
    };

    let articles: Vec<Article> = parsed
        .entries
        .iter()
        .map(|entry| Article {
            id: utils::generate_id_from_data(entry.id.as_bytes()),
            feed_id: feed.id.clone(),
            title: entry
                .title
                .as_ref()
                .map(|it| it.content.clone())
                .unwrap_or_else(|| entry.id.clone()),
            url: entry.links.get(0).map(|it| it.href.clone()),
            html_content: entry.content.as_ref().and_then(|it| it.body.clone()),
        })
        .collect();

    let categories: Vec<FeedCategory> = parsed
        .categories
        .iter()
        .map(|it| FeedCategory {
            feed_id: feed.id.clone(),
            category_name: it.term.clone(),
        })
        .collect();

    let subscription = Subscription {
        user_id: user.id.clone(),
        feed_id: feed.id.clone(),
    };

    req.state()
        .repo
        .run(move |conn| {
            let exists: bool =
                sql::select(sql::exists(feeds::table.find(&feed.id))).get_result(conn)?;

            if exists {
                let _: Feed = feed.save_changes(conn.deref())?;
                for article in &articles {
                    let _: Article = article.save_changes(conn.deref())?;
                }
                diesel::delete(
                    feed_categories::table.filter(feed_categories::feed_id.eq(&feed.id)),
                )
                .execute(conn)?;
                diesel::insert_into(feed_categories::table)
                    .values(&categories)
                    .execute(conn)?;
                diesel::insert_or_ignore_into(subscriptions::table)
                    .values(&subscription)
                    .execute(conn)?;
            } else {
                diesel::insert_into(feeds::table)
                    .values(&feed)
                    .execute(conn)?;
                diesel::insert_into(articles::table)
                    .values(&articles)
                    .execute(conn)?;
                diesel::insert_into(feed_categories::table)
                    .values(&categories)
                    .execute(conn)?;
                diesel::insert_into(subscriptions::table)
                    .values(&subscription)
                    .execute(conn)?;
            }

            Ok::<_, tide::Error>(())
        })
        .await?;

    return Ok(Response::new(200));
}

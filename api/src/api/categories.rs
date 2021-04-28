use std::collections::BTreeMap;

use diesel::prelude::*;
use tide::{Request, StatusCode};

use crate::db::models::Feed;
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

    let results: Vec<(String, Feed)> = req
        .state()
        .repo
        .run({
            let user_id = user.id.clone();
            move |conn| {
                feeds::table
                    .inner_join(feed_categories::table)
                    .inner_join(subscriptions::table)
                    .select((feed_categories::category_name, feeds::all_columns))
                    .filter(subscriptions::user_id.eq(user_id))
                    .load(conn)
            }
        })
        .await?;

    let mut categories: BTreeMap<String, Vec<Feed>> = BTreeMap::new();
    for (category, feed) in results {
        categories
            .entry(category)
            .and_modify(|feeds| feeds.push(feed.clone()))
            .or_insert_with(|| vec![feed.clone()]);
    }

    Ok(utils::response::json(&categories))
}

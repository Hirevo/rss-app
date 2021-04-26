use tide::{Request, Response};

pub mod account;
pub mod article;
pub mod articles;
pub mod categories;
pub mod feed;
pub mod feeds;

use crate::State;

pub async fn get(_: Request<State>) -> tide::Result {
    Ok(Response::builder(200).body("hello, world !").build())
}

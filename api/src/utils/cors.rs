use tide::http::headers::{self, HeaderValue};
use tide::http::Method;
use tide::utils::async_trait;
use tide::{Body, Middleware, Next, Request, Response};

#[derive(Debug, Clone)]
pub struct CorsMiddleware {
    max_age: HeaderValue,
    methods: HeaderValue,
    origin: HeaderValue,
    headers: HeaderValue,
}

impl Default for CorsMiddleware {
    fn default() -> Self {
        Self {
            max_age: DEFAULT_MAX_AGE.parse().unwrap(),
            methods: DEFAULT_METHODS.parse().unwrap(),
            origin: STAR.parse().unwrap(),
            headers: STAR.parse().unwrap(),
        }
    }
}

pub const DEFAULT_MAX_AGE: &str = "86400";
pub const DEFAULT_METHODS: &str = "GET, POST, OPTIONS";
pub const STAR: &str = "*";

impl CorsMiddleware {
    pub fn new() -> Self {
        CorsMiddleware::default()
    }

    pub fn max_age<S: Into<HeaderValue>>(mut self, max_age: S) -> Self {
        self.max_age = max_age.into();
        self
    }

    pub fn methods<S: Into<HeaderValue>>(mut self, methods: S) -> Self {
        self.methods = methods.into();
        self
    }

    pub fn origin<S: Into<HeaderValue>>(mut self, origin: S) -> Self {
        self.origin = origin.into();
        self
    }

    pub fn headers<S: Into<HeaderValue>>(mut self, headers: S) -> Self {
        self.headers = headers.into();
        self
    }
}

#[async_trait]
impl<State: Clone + Send + Sync + 'static> Middleware<State> for CorsMiddleware {
    async fn handle(&self, req: Request<State>, next: Next<'_, State>) -> tide::Result {
        if req.method() == Method::Options {
            return Ok(Response::builder(200)
                .header(headers::ACCESS_CONTROL_ALLOW_ORIGIN, self.origin.clone())
                .header(headers::ACCESS_CONTROL_ALLOW_METHODS, self.methods.clone())
                .header(headers::ACCESS_CONTROL_ALLOW_HEADERS, self.headers.clone())
                .header(headers::ACCESS_CONTROL_MAX_AGE, self.max_age.clone())
                .body(Body::empty())
                .build());
        }
        let mut res = next.run(req).await;
        res.insert_header(headers::ACCESS_CONTROL_ALLOW_ORIGIN, self.origin.clone());
        Ok(res)
    }
}

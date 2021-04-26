use diesel::r2d2::{self, ConnectionManager, Pool, PooledConnection};

use crate::config::database::DatabaseConfig;

/// The database models (struct representations of tables).
pub mod models;
/// The database schema definitions (in SQL types).
pub mod schema;

/// The format in which datetime records are saved in the database.
pub static DATETIME_FORMAT: &str = "%Y-%m-%d %H:%M:%S";

/// The connection type (MySQL database).
pub type Connection = diesel::mysql::MysqlConnection;

/// A database "repository", for running database workloads.
/// Manages a connection pool and running blocking tasks in a
/// way that does not block the tokio event loop.
#[derive(Debug)]
pub struct Repo<T>
where
    T: diesel::Connection + 'static,
{
    connection_pool: Pool<ConnectionManager<T>>,
}

impl<T> Clone for Repo<T>
where
    T: diesel::Connection + 'static,
{
    fn clone(&self) -> Self {
        Self {
            connection_pool: self.connection_pool.clone(),
        }
    }
}

impl<T> Repo<T>
where
    T: diesel::Connection + 'static,
{
    /// Constructs a `Repo<T>` for the given database config (creates a connection pool).
    pub fn new(database_config: &DatabaseConfig) -> Self {
        let mut builder = r2d2::Builder::default();
        if let Some(max_size) = database_config.max_conns {
            builder = builder.max_size(max_size)
        }

        Self::from_pool_builder(&database_config.url, builder)
    }

    /// Creates a `Repo<T>` with a custom connection pool builder.
    pub fn from_pool_builder(
        database_url: &str,
        builder: diesel::r2d2::Builder<ConnectionManager<T>>,
    ) -> Self {
        let manager = ConnectionManager::new(database_url);
        let connection_pool = builder
            .build(manager)
            .expect("could not initiate test db pool");
        Repo { connection_pool }
    }

    /// Runs the given closure in a way that is safe for blocking IO to the database.
    /// The closure will be passed a `Connection` from the pool to use.
    pub async fn run<F, R>(&self, f: F) -> R
    where
        F: FnOnce(&PooledConnection<ConnectionManager<T>>) -> R + Send + 'static,
        R: Send + 'static,
        T: Send,
    {
        let pool = self.connection_pool.clone();
        let future = async_std::task::spawn_blocking(move || {
            let conn = pool.get().unwrap();
            f(&conn)
        });

        future.await
    }

    /// Runs the given closure in a way that is safe for blocking IO to the database.
    /// The closure will be passed a `Connection` from the pool to use.
    /// This closure will run in the context of a database transaction.
    /// If an error occurs, the database changes made in this closure will get rolled back to their original state.
    pub async fn transaction<F, R, E>(&self, f: F) -> Result<R, E>
    where
        F: FnOnce(&PooledConnection<ConnectionManager<T>>) -> Result<R, E> + Send + 'static,
        T: Send,
        R: Send + 'static,
        E: From<diesel::result::Error> + Send + 'static,
    {
        let pool = self.connection_pool.clone();
        let future = async_std::task::spawn_blocking(move || {
            let conn = pool.get().unwrap();
            conn.transaction(|| f(&conn))
        });

        future.await
    }
}

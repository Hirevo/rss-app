<script>
    import { onMount } from "svelte";

    import { Route, Router, navigate } from "svelte-routing";

    import Home from "./views/Home.svelte";
    import Login from "./views/Login.svelte";
    import Register from "./views/Register.svelte";
    import Feeds from "./views/Feeds.svelte";
    import Articles from "./views/Articles.svelte";
    import Article from "./views/Article.svelte";
    import Categories from "./views/Categories.svelte";
    import CategoryFeeds from "./views/CategoryFeeds.svelte";
    import Settings from "./views/Settings.svelte";

    import state from "./state";

    export let url = "";

    onMount(() => {
        if (window.location.pathname === "/") {
            const paramsString = window.location.search;
            const searchParams = new URLSearchParams(paramsString);
            const token = searchParams.get("token");
            if (token != undefined) {
                localStorage.setItem("token", token);
                navigate("/");
            }
        }

        const token = localStorage.getItem("token");
        if (token != undefined) {
            state.loginFromToken(token)
                .then(() => {
                    if (window.location.pathname === "/login" || window.location.pathname === "/register") {
                        navigate("/");
                    }
                })
                .catch((err) => {
                    if (window.location.pathname !== "/login" && window.location.pathname !== "/register") {
                        navigate("/login");
                    }
                    console.error("could not login from saved token:", err);
                });
        } else if (window.location.pathname !== "/login" && window.location.pathname !== "/register") {
            navigate("/login");
        }
    });
</script>

<Router {url}>
    <div class="root">
        <Route path="/" let:params>
            <Home />
        </Route>
        <Route path="/login" let:params>
            <Login />
        </Route>
        <Route path="/register" let:params>
            <Register />
        </Route>
        <Route path="/feeds" let:params>
            <Feeds />
        </Route>
        <Route path="/articles/:feed-id" let:params>
            <Articles feedId={params["feed-id"]} />
        </Route>
        <Route path="/article/:article-id" let:params>
            <Article articleId={params["article-id"]} />
        </Route>
        <Route path="/categories" let:params>
            <Categories />
        </Route>
        <Route path="/category/:category" let:params>
            <CategoryFeeds category={params["category"]} />
        </Route>
        <Route path="/settings" let:params>
            <Settings />
        </Route>
    </div>
</Router>

<style>
    .root {
        width: 100%;
        height: 100%;
    }
</style>

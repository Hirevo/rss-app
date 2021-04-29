<script lang="ts">
    import Icon from "fa-svelte";
    import { Link, navigate } from "svelte-routing";

    import { faGoogle } from "@fortawesome/free-brands-svg-icons/faGoogle";

    import Button from "./Button.svelte";

    import state from "../state";
    import locations from "../locations";

    let email = "";
    let password = "";

    let loading = false;
    function login() {
        loading = true;
        state.login(email, password).then(() => {
            loading = false;
            locations.clear();
        });
    }
</script>

<div class="root">
    <div class="navbar">
        <div class="title-container">
            <div class="title">RSS App</div>
        </div>
    </div>
    <div class="content-container centered">
        <div class="content vstack">
            <div class="page-label centered">
                Login to RSS App
            </div>
            <div>
                <input
                    class="input"
                    type="text"
                    name="email"
                    id="email"
                    bind:value={email}
                    autocomplete="email"
                    placeholder="Enter email..."
                >
            </div>
            <div>
                <input
                    class="input"
                    type="password"
                    name="password"
                    id="password"
                    bind:value={password}
                    autocomplete="current-password"
                    placeholder="Enter password..."
                >
            </div>
            <div><Button on:click={login}>Log in</Button></div>
            <div><Link to="/register"><Button>Need to create an account ?</Button></Link></div>
            <div class="separator-container">
                <div class="separator"></div>
                <div class="separator-text">OR</div>
                <div class="separator"></div>
            </div>
            <div>
                <a href={`API_ORIGIN/auth/google?redirect_url=${encodeURIComponent("APP_ORIGIN")}`}>
                    <Button>
                        <div class="google">
                            <div class="centered"><Icon icon={faGoogle} /></div>
                            <div>Login with Google</div>
                        </div>
                    </Button>
                </a>
            </div>
        </div>
    </div>
</div>

<style>
    .root {
        width: 100%;
        height: 100%;
        display: grid;
        grid-template-columns: 100%;
        grid-template-rows: 50px calc(100% - 50px);
    }

    .navbar {
        width: 100%;
        height: 100%;
        border-bottom: 2px solid var(--fg-color);
        /* font-weight: bold; */
        font-size: 20px;
        display: grid;
        grid-template-columns: 1fr;
        grid-template-rows: 1fr;
        grid-gap: 5px;
        padding: 2px;

        --font-wght: 800;
    }

    .title-container {
        display: flex;
        align-items: center;
        justify-content: center;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
        padding: 0 10px;
    }

    .title {
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
        cursor: pointer;
    }

    .button-container {
        height: 100%;
    }

    .content-container {
        width: 100%;
        height: 100%;
    }

    .content {
        width: 100%;
        max-width: 600px;

        --button-padding: 7px;
    }

    .content > * {
        margin-top: 10px;
    }

    .content > *:first-child {
        margin-top: 0;
    }

    .page-label {
        text-align: center;
        font-size: 22px;
        /* font-weight: 800; */

        --font-wght: 800;
    }

    .message {
        width: 100%;
        height: 100%;
        text-align: center;
        font-size: 22px;
        /* font-weight: 800; */

        --font-wght: 800;
    }

    .separator-container {
        width: 100%;
        display: grid;
        grid-template-rows: 1fr;
        grid-template-columns: 1fr min-content 1fr;
        grid-gap: 10px;
        align-items: center;
        justify-content: center;
    }

    .separator {
        width: 100%;
        height: 2px;
        background-color: var(--fg-color);
    }

    .separator-text {
        width: 100%;
        height: 100%;
        text-align: center;
        font-size: 18px;
        /* font-weight: 800; */

        --font-wght: 800;
    }

    .discrete {
        color: #777;
    }

    .google {
        display: grid;
        grid-template-rows: 1fr;
        grid-template-columns: min-content 1fr;
        grid-gap: 5px;
        align-items: center;
        justify-content: center;
    }

    .input {
        appearance: none;
        -moz-appearance: none;
        -webkit-appearance: none;

        width: 100%;
        padding: 7px;
        margin: 0;

        color: inherit;
        background-color: inherit;

        font-family: inherit;
        font-size: inherit;
        font-weight: inherit;
        text-align: center;

        border: solid 2px var(--fg-color);
        border-radius: 5px;

        outline: none;
    }

    .context-overlay {
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
    }

    .context-menu {
        position: absolute;
        border: 2px solid var(--fg-color);
        border-radius: 5px;
        background-color: var(--bg-color);
        white-space: nowrap;
    }

    .context-menu-size {
        border-bottom: solid 2px var(--fg-color);
        padding: 10px;
        color: #7f7f7f;
        display: flex;
        align-items: center;
        justify-content: center;
    }

    .context-menu-item-container {
        padding: 5px;
    }

    .context-menu-item {
        border-radius: 5px;
        padding: 5px 10px;
        cursor: pointer;
    }

    .context-menu-item:hover {
        color: var(--bg-color);
        background-color: var(--fg-color);
    }
</style>

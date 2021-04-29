<script lang="ts">
    import Icon from "fa-svelte";
    import { Link, navigate } from "svelte-routing";

    import { faArrowLeft } from "@fortawesome/free-solid-svg-icons/faArrowLeft";

    import Button from "./Button.svelte";

    import state, { ProfileData } from "../state";
    import locations from "../locations";

    let profileData: Promise<ProfileData> = state.ready
        .then(() => state.profileData);

    function logout() {
        state.logout().then(() => {
            navigate("/login");
        });
    }

    function goBack() {
        locations.pop();
    }

    function goTo(location: string) {
        return function () {
            locations.push(location);
        }
    }
</script>

<div class="root">
    <div class="navbar">
        <div class="button-container">
            <Button on:click={goBack}><Icon icon={faArrowLeft} /></Button>
        </div>
        <div class="title-container">
            <div class="title">Settings</div>
        </div>
    </div>
    <div class="content-container centered">
        <div class="content vstack" style="gap: 10px">
            {#await profileData}
                <div class="message">Loading profile...</div>
            {:then profileData}
                <div class="hstack centered" style="gap: 5px">
                    <div>Logged in as:</div>
                    <div class="outline">
                        {profileData.name}
                    </div>
                </div>
                <div class="hstack centered" style="gap: 5px">
                    <div>Email:</div>
                    <div class="outline">
                        {profileData.email}
                    </div>
                </div>
                <div class="logout-button">
                    <Button on:click={logout}>
                        Log out
                    </Button>
                </div>
            {/await}
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
        grid-template-columns: 75px 1fr;
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
        white-space: nowrap;
    }

    .content-container {
        width: 100%;
        height: 100%;
    }

    .content {
    }

    .logout-button {
        --button-padding: 10px;
    }

    .outline {
        padding: 2px 5px;
        border-radius: 5px;
        border: solid 2px var(--fg-color);

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
</style>

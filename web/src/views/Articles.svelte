<script lang="ts">
    import { onMount, tick } from "svelte";

    import Icon from "fa-svelte";
    import { Link } from "svelte-routing";

    import { faArrowLeft } from "@fortawesome/free-solid-svg-icons/faArrowLeft";
    import { faRedoAlt } from "@fortawesome/free-solid-svg-icons/faRedoAlt";
    import { faCheckCircle } from "@fortawesome/free-solid-svg-icons/faCheckCircle";

    import Button from "./Button.svelte";

    import state from "../state";
    import locations from "../locations";
    import type { Article } from "../types";

    export let feedId: string;

    let refreshing = true;
    let articles: Promise<Article[]> = state.ready
        .then(() => state.articles(feedId))
        .then((articles) => {
            refreshing = false;
            return articles;
        });

    function refreshArticles() {
        refreshing = true;
        articles = state.articles(feedId).then((articles) => {
            refreshing = false;
            return articles;
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

    let contextMenuElement;
    let contextData = undefined;
    let contextTop = 0;
    let contextLeft = 0;
    function openContextMenu(article: Article) {
        return function (event: MouseEvent) {
            const { pageX, pageY } = event;

            contextData = {
                article,
                items: [{
                    label: article.markedAsRead ? "Mark as Unread" : "Mark as Read",
                    handler: () => {
                        state.markAsRead(article.id, !article.markedAsRead)
                            .then(() => refreshArticles());
                    },
                }],
            };

            contextLeft = pageX;
            contextTop = pageY;

            tick().then(() => {
                const rect = contextMenuElement.getBoundingClientRect();
                if (rect.top < 0) {
                    contextTop += rect.top;
                }
                if (rect.bottom > document.body.clientHeight) {
                    contextTop -= rect.bottom - document.body.clientHeight;
                }
                if (rect.left < 0) {
                    contextLeft += rect.left;
                }
                if (rect.right > document.body.clientWidth) {
                    contextLeft -= rect.right - document.body.clientWidth;
                }
            });
        };
    }
    function handleContextMenuItemClick(handler) {
        return function () {
            handler();
            closeContextMenu();
        };
    }
    function closeContextMenu() {
        contextData = undefined;
    }
</script>

<div class="root">
    <div class="navbar">
        <div class="button-container">
            <Button on:click={goBack}><Icon icon={faArrowLeft} /></Button>
        </div>
        <div class="title-container">
            <div class="title">Articles</div>
        </div>
        <div class="button-container">
            <Button disabled={refreshing} on:click={refreshArticles}>
                <div class="refresher centered" class:refreshing>
                    <Icon icon={faRedoAlt} />
                </div>
            </Button>
        </div>
    </div>
    <div class="content-container centered">
        <div class="content vstack" style="gap: 10px">
            {#await articles}
                <div class="message">Loading articles...</div>
            {:then articles}
                {#each articles as article (article.id)}
                    <div class="article-button" on:contextmenu|preventDefault={openContextMenu(article)}>
                        <Button on:click={goTo(`/article/${encodeURIComponent(article.id)}`)}>
                            <div class="hstack centered" style="width: 100%; gap: 10px">
                                <div class="centered" style="flex-grow: 1">
                                    {article.title}
                                </div>
                                {#if article.markedAsRead}
                                    <div class="centered">
                                        <Icon icon={faCheckCircle} />
                                    </div>
                                {/if}
                            </div>
                        </Button>
                    </div>
                {:else}
                    <div class="message discrete">No articles.</div>
                {/each}
            {/await}
        </div>
    </div>
    {#if contextData}
        <div class="context-overlay" on:click={closeContextMenu} />
        <div class="context-menu vstack" style={`top: ${contextTop}px; left: ${contextLeft}px;`} bind:this={contextMenuElement}>
            <div class="context-menu-size">{contextData.article.title}</div>
            <div class="context-menu-item-container">
                {#each contextData.items as { label, handler }}
                    <div class="context-menu-item" on:click={handleContextMenuItemClick(handler)}>{label}</div>
                {/each}
            </div>
        </div>
    {/if}
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
        grid-template-columns: 75px 1fr repeat(2, min-content);
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

    .refreshing {
        will-change: transform;
        transform-origin: center;
        animation-name: spinning;
        animation-duration: 1s;
        animation-direction: normal;
        animation-timing-function: linear;
        animation-iteration-count: infinite;
    }

    @keyframes spinning {
        from {
            transform: rotate(0deg);
        }

        to {
            transform: rotate(360deg);
        }
    }

    .content-container {
        width: 100%;
        height: 100%;
        overflow: auto;
        padding: 10px;
    }

    .content {
    }

    .article-button {
        flex-grow: 1;

        --button-padding: 10px 20px;
    }

    .message {
        width: 100%;
        height: 100%;
        text-align: center;
        font-size: 22px;
        /* font-weight: 800; */

        --font-wght: 800;
    }

    .discrete {
        color: #777;
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

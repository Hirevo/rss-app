<script lang="ts">
    import { onMount, tick } from "svelte";

    import Showdown from "showdown";

    import Icon from "fa-svelte";
    import { Link } from "svelte-routing";

    import { faArrowLeft } from "@fortawesome/free-solid-svg-icons/faArrowLeft";
    import { faRedoAlt } from "@fortawesome/free-solid-svg-icons/faRedoAlt";

    import Button from "./Button.svelte";

    import state from "../state";
    import locations from "../locations";
    import type { Article } from "../types";

    export let articleId: string;

    let refreshing = true;
    let article: Promise<Article> = state.ready
        .then(() => state.article(articleId))
        .then((article) => {
            state.markAsRead(article.id);
            refreshing = false;
            renderMarkdown(article);
            return article;
        });

    function refreshArticle() {
        refreshing = true;
        article = state.article(articleId).then((article) => {
            refreshing = false;
            renderMarkdown(article);
            return article;
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

    let renderedHtml: string | undefined;
    function renderMarkdown(article: Article) {
        if (article.htmlContent != undefined) {
            const converter = new Showdown.Converter();
            renderedHtml = converter.makeHtml(article.htmlContent);
        }
    }
</script>

<div class="root">
    <div class="navbar">
        <div class="button-container">
            <Button on:click={goBack}><Icon icon={faArrowLeft} /></Button>
        </div>
        <div class="title-container">
            <div class="title">
                {#await article}
                    Article
                {:then article}
                    {article.title}
                {:catch}
                    Article
                {/await}
            </div>
        </div>
        <div class="button-container">
            <Button disabled={refreshing} on:click={refreshArticle}>
                <div class="refresher centered" class:refreshing>
                    <Icon icon={faRedoAlt} />
                </div>
            </Button>
        </div>
    </div>
    <div class="content-container">
        {#await article}
            <div class="message">Loading article...</div>
        {:then article}
            {#if article.htmlContent != undefined}
                <div class="markdown vstack" style="gap: 10px">
                    {@html renderedHtml}
                </div>
            {:else if article.url != undefined}
                <iframe class="iframe" title={article.url} src={article.url}></iframe>
            {:else}
                <div class="markdown centered" style="gap: 10px">
                    <div class="message discrete">Empty.</div>
                </div>
            {/if}
        {/await}
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

    .markdown * {
        margin: 2px;
    }

    .iframe {
        width: 100%;
        height: 99%;
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
</style>

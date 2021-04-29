<script>
    // ADAPTED FROM: https://tobiasahlin.com/spinkit/
</script>

<div class="root">
    <div class="cube cube1" />
    <div class="cube cube2" />
    <div class="cube cube3" />
    <div class="cube cube4" />
    <div class="cube cube5" />
    <div class="cube cube6" />
    <div class="cube cube7" />
    <div class="cube cube8" />
    <div class="cube cube9" />
</div>

<style>
    .root {
        width: 40px;
        height: 40px;
        margin: 100px auto;
    }

    .cube {
        width: 33%;
        height: 33%;
        background-color: var(--fg-color);
        float: left;
        -webkit-animation: cubeGridScaleDelay 1.3s infinite ease-in-out;
        animation: cubeGridScaleDelay 1.3s infinite ease-in-out;
    }
    .cube1 {
        -webkit-animation-delay: 0.2s;
        animation-delay: 0.2s;
    }
    .cube2 {
        -webkit-animation-delay: 0.3s;
        animation-delay: 0.3s;
    }
    .cube3 {
        -webkit-animation-delay: 0.4s;
        animation-delay: 0.4s;
    }
    .cube4 {
        -webkit-animation-delay: 0.1s;
        animation-delay: 0.1s;
    }
    .cube5 {
        -webkit-animation-delay: 0.2s;
        animation-delay: 0.2s;
    }
    .cube6 {
        -webkit-animation-delay: 0.3s;
        animation-delay: 0.3s;
    }
    .cube7 {
        -webkit-animation-delay: 0s;
        animation-delay: 0s;
    }
    .cube8 {
        -webkit-animation-delay: 0.1s;
        animation-delay: 0.1s;
    }
    .cube9 {
        -webkit-animation-delay: 0.2s;
        animation-delay: 0.2s;
    }

    @-webkit-keyframes cubeGridScaleDelay {
        0%,
        70%,
        100% {
            -webkit-transform: scale3D(1, 1, 1);
            transform: scale3D(1, 1, 1);
        }
        35% {
            -webkit-transform: scale3D(0, 0, 1);
            transform: scale3D(0, 0, 1);
        }
    }

    @keyframes cubeGridScaleDelay {
        0%,
        70%,
        100% {
            -webkit-transform: scale3D(1, 1, 1);
            transform: scale3D(1, 1, 1);
        }
        35% {
            -webkit-transform: scale3D(0, 0, 1);
            transform: scale3D(0, 0, 1);
        }
    }
</style>

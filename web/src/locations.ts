import type { Feed, Article } from "./types";

import { navigate } from "svelte-routing";

export class AppLocationManager {
    locations: string[] = [];

    get current(): string | undefined {
        return (this.locations.length > 0) ? this.locations[this.locations.length - 1] : undefined;
    }

    push(location: string) {
        this.locations.push(location);
        this.navigateToCurrent();
    }

    pop() {
        this.locations.pop();
        this.navigateToCurrent();
    }

    clear() {
        this.locations = [];
        this.navigateToCurrent();
    }

    navigateToCurrent() {
        const current = this.current;
        if (current === undefined) {
            navigate("/");
        } else {
            navigate(current);
        }
    }
}

export const locations = new AppLocationManager();

export default locations;

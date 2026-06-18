class Observable {
    constructor(initialValue) {
        this.value = initialValue
        this.subscribers = []
    }

    set(newValue) {
        if (this.value !== newValue) {
            this.value = newValue
            this.subscribers.forEach(subscriber => subscriber(this.value))
            return true
        }
        return false
    }

    get() {
        return this.value
    }

    subscribe(handler) {
        this.subscribers.push(handler)
    }

    unsubscribe(handler) {
        this.subscribers = this.subscribers.filter(currentHandler => currentHandler !== handler)
    }
}

export default Observable

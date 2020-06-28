module agj.utils.bounds;

struct AABB(T) {
    T minBoundX, maxBoundX;
    T minBoundY, maxBoundY;
    bool initialized = false;

    void grow (T x, T y) {
        if (!initialized) {
            initialized = true;
            minBoundX = maxBoundX = x;
            minBoundY = maxBoundY = y;
        } else {
            if (x < minBoundX) minBoundX = x;
            if (x > maxBoundX) maxBoundX = x;
            if (y < minBoundY) minBoundY = y;
            if (y > maxBoundY) maxBoundY = y;
        }
    }
}

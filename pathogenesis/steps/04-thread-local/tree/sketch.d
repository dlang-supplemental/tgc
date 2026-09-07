/**
 * Pedagogical sketch — TLS heap.
 * Step 04: each thread owns a Heap; collect is local.
 */
module pathogenesis.step04;

struct Heap
{
    // same fields as earlier steps…
    size_t usedBytes;
}

static Heap* tlsHeap;

Heap* currentHeap()
{
    if (!tlsHeap)
    {
        import core.stdc.stdlib : calloc;
        tlsHeap = cast(Heap*) calloc(1, Heap.sizeof);
    }
    return tlsHeap;
}

void collectLocal()
{
    auto h = currentHeap();
    // markFromStack(h, …); sweep(h);  — only this thread's roots
    cast(void) h;
}

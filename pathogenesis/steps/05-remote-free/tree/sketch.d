/**
 * Pedagogical sketch — ownership-transfer free.
 * Step 05: foreign free enqueues; owner drains.
 */
module pathogenesis.step05;

struct Heap
{
    void** remotePtrs;
    size_t remoteLen;
    size_t remoteCap;
    // SpinLock remoteLock;  — elided in sketch
}

void pushRemote(Heap* owner, void* p)
{
    // lock; grow remotePtrs if needed; remotePtrs[remoteLen++] = p; unlock;
    cast(void) owner;
    cast(void) p;
}

void drainRemote(Heap* owner)
{
    // lock; take ptrs; clear len; unlock; unlinkAndFree each local header
    cast(void) owner;
}

void freeMaybeRemote(Heap* local, Heap* ownerOfBlock, void* p)
{
    if (ownerOfBlock is local)
    {
        // unlinkAndFree locally
        cast(void) p;
        return;
    }
    pushRemote(ownerOfBlock, p);
}

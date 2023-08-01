import pytest

from hbayesdm.models import bart_policy


def test_bart_policy():
    _ = bart_policy(
        data="example", niter=10, nwarmup=5, nchain=1, ncore=1)


if __name__ == '__main__':
    pytest.main()

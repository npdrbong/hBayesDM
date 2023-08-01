import pytest

from hbayesdm.models import bart_bias


def test_bart_bias():
    _ = bart_bias(
        data="example", niter=10, nwarmup=5, nchain=1, ncore=1)


if __name__ == '__main__':
    pytest.main()

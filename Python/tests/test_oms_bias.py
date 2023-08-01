import pytest

from hbayesdm.models import oms_bias


def test_oms_bias():
    _ = oms_bias(
        data="example", niter=10, nwarmup=5, nchain=1, ncore=1)


if __name__ == '__main__':
    pytest.main()

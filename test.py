import cocotb
from cocotb.triggers import *

# https://docs.cocotb.org/en/stable/writing_testbenches.html
@cocotb.test()
async def simple_xor(dut):
    """Try accessing the design."""

    dut.a.value = 1;
    dut.b.value = 0;
    await Timer(1) # https://docs.cocotb.org/en/stable/timing_model.html

    cocotb.log.info("out is %s", dut.o.value)
    assert dut.o.value == 1

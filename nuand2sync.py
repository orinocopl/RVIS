#!/usr/bin/env python3
# -*- coding: utf-8 -*-

#
# SPDX-License-Identifier: GPL-3.0
#
# GNU Radio Python Flow Graph
# Title: Not titled yet
# GNU Radio version: 3.10.12.0

from gnuradio import blocks
from gnuradio import gr
from gnuradio.filter import firdes
from gnuradio.fft import window
import sys
import signal
from argparse import ArgumentParser
from gnuradio.eng_arg import eng_float, intx
from gnuradio import eng_notation
import bladeRF
import time
import threading




class nuand2sync(gr.top_block):

    def __init__(self, bandwidth=2000000, gain4=(-1), nosamples=50000000, sps=10000000, tuning=868000000):
        gr.top_block.__init__(self, "Not titled yet", catch_exceptions=True)
        self.flowgraph_started = threading.Event()

        ##################################################
        # Parameters
        ##################################################
        self.bandwidth = bandwidth
        self.gain4 = gain4
        self.nosamples = nosamples
        self.sps = sps
        self.tuning = tuning

        ##################################################
        # Blocks
        ##################################################

        self.blocks_multiply_const_vxx_0_1 = blocks.multiply_const_cc(32767)
        self.blocks_multiply_const_vxx_0_0_0 = blocks.multiply_const_cc(32767)
        self.blocks_multiply_const_vxx_0_0 = blocks.multiply_const_cc(32767)
        self.blocks_multiply_const_vxx_0 = blocks.multiply_const_cc(32767)
        self.blocks_head_0_1 = blocks.head(gr.sizeof_gr_complex*1, nosamples)
        self.blocks_head_0_0_0 = blocks.head(gr.sizeof_gr_complex*1, nosamples)
        self.blocks_head_0_0 = blocks.head(gr.sizeof_gr_complex*1, nosamples)
        self.blocks_head_0 = blocks.head(gr.sizeof_gr_complex*1, nosamples)
        self.blocks_file_sink_0_1 = blocks.file_sink(gr.sizeof_short*1, '/tmp/nuand2.bin', False)
        self.blocks_file_sink_0_1.set_unbuffered(False)
        self.blocks_file_sink_0_0_0 = blocks.file_sink(gr.sizeof_short*1, '/tmp/nuand3.bin', False)
        self.blocks_file_sink_0_0_0.set_unbuffered(False)
        self.blocks_file_sink_0_0 = blocks.file_sink(gr.sizeof_short*1, '/tmp/nuand1.bin', False)
        self.blocks_file_sink_0_0.set_unbuffered(False)
        self.blocks_file_sink_0 = blocks.file_sink(gr.sizeof_short*1, '/tmp/nuand0.bin', False)
        self.blocks_file_sink_0.set_unbuffered(False)
        self.blocks_complex_to_interleaved_short_0_1 = blocks.complex_to_interleaved_short(False,1.0)
        self.blocks_complex_to_interleaved_short_0_0_0 = blocks.complex_to_interleaved_short(False,1.0)
        self.blocks_complex_to_interleaved_short_0_0 = blocks.complex_to_interleaved_short(False,1.0)
        self.blocks_complex_to_interleaved_short_0 = blocks.complex_to_interleaved_short(False,1.0)
        self.bladeRF_source_0_0 = bladeRF.source(
            args="numchan=" + str(2)
                 + ",metadata=" + 'False'
                 + ",bladerf=" +  str('f3e9a1d78d7d4041afd8dbd9ab1a76e4')
                 + ",verbosity=" + 'verbose'
                 + ",feature=" + 'default'
                 + ",sample_format=" + '16bit'
                 + ",fpga=" + str('')
                 + ",fpga-reload=" + 'False'
                 + ",use_ref_clk=" + 'False'
                 + ",ref_clk=" + str(int(38400000))
                 + ",buflen=" + str(int(32768))
                 + ",buffers=" + str(int(4096))
                 + ",in_clk=" + 'EXTERNAL'
                 + ",out_clk=" + str(False)
                 + ",use_dac=" + 'False'
                 + ",dac=" + str(10000)
                 + ",xb200=" + 'none'
                 + ",tamer=" + 'internal'
                 + ",sampling=" + 'internal'
                 + ",lpf_mode="+'disabled'
                 + ",smb="+str(int(38.4e6))
                 + ",dc_calibration="+'LPF_TUNING'
                 + ",trigger0="+'True'
                 + ",trigger_role0="+'slave'
                 + ",trigger_signal0="+'J51_1'
                 + ",trigger1="+'False'
                 + ",trigger_role1="+'slave'
                 + ",trigger_signal1="+'J51_1'
                 + ",bias_tee0="+'False'
                 + ",bias_tee1="+'False'


        )
        self.bladeRF_source_0_0.set_sample_rate(sps)
        self.bladeRF_source_0_0.set_center_freq(tuning,0)
        self.bladeRF_source_0_0.set_bandwidth(bandwidth,0)
        self.bladeRF_source_0_0.set_dc_offset_mode(0, 0)
        self.bladeRF_source_0_0.set_iq_balance_mode(0, 0)
        self.bladeRF_source_0_0.set_gain_mode(False, 0)
        self.bladeRF_source_0_0.set_gain(gain4, 0)
        self.bladeRF_source_0_0.set_if_gain(0, 0)
        self.bladeRF_source_0_0.set_dc_offset_mode(0, 1)
        self.bladeRF_source_0_0.set_iq_balance_mode(0, 1)
        self.bladeRF_source_0_0.set_gain_mode(False, 1)
        self.bladeRF_source_0_0.set_gain(gain4, 1)
        self.bladeRF_source_0_0.set_if_gain(0, 1)
        self.bladeRF_source_0 = bladeRF.source(
            args="numchan=" + str(2)
                 + ",metadata=" + 'False'
                 + ",bladerf=" +  str('0ab3220d828942b4a34ec09db0c8970c')
                 + ",verbosity=" + 'verbose'
                 + ",feature=" + 'default'
                 + ",sample_format=" + '16bit'
                 + ",fpga=" + str('')
                 + ",fpga-reload=" + 'False'
                 + ",use_ref_clk=" + 'False'
                 + ",ref_clk=" + str(int(38400000))
                 + ",buflen=" + str(int(32768))
                 + ",buffers=" + str(int(4096))
                 + ",in_clk=" + 'EXTERNAL'
                 + ",out_clk=" + str(False)
                 + ",use_dac=" + 'False'
                 + ",dac=" + str(10000)
                 + ",xb200=" + 'none'
                 + ",tamer=" + 'internal'
                 + ",sampling=" + 'internal'
                 + ",lpf_mode="+'disabled'
                 + ",smb="+str(int(38.4e6))
                 + ",dc_calibration="+'LPF_TUNING'
                 + ",trigger0="+'True'
                 + ",trigger_role0="+'master'
                 + ",trigger_signal0="+'J51_1'
                 + ",trigger1="+'False'
                 + ",trigger_role1="+'slave'
                 + ",trigger_signal1="+'J51_1'
                 + ",bias_tee0="+'False'
                 + ",bias_tee1="+'False'


        )
        self.bladeRF_source_0.set_sample_rate(sps)
        self.bladeRF_source_0.set_center_freq(tuning,0)
        self.bladeRF_source_0.set_bandwidth(bandwidth,0)
        self.bladeRF_source_0.set_dc_offset_mode(0, 0)
        self.bladeRF_source_0.set_iq_balance_mode(0, 0)
        self.bladeRF_source_0.set_gain_mode(False, 0)
        self.bladeRF_source_0.set_gain(gain4, 0)
        self.bladeRF_source_0.set_if_gain(0, 0)
        self.bladeRF_source_0.set_dc_offset_mode(0, 1)
        self.bladeRF_source_0.set_iq_balance_mode(0, 1)
        self.bladeRF_source_0.set_gain_mode(False, 1)
        self.bladeRF_source_0.set_gain(gain4, 1)
        self.bladeRF_source_0.set_if_gain(0, 1)


        ##################################################
        # Connections
        ##################################################
        self.connect((self.bladeRF_source_0, 0), (self.blocks_head_0, 0))
        self.connect((self.bladeRF_source_0, 1), (self.blocks_head_0_0, 0))
        self.connect((self.bladeRF_source_0_0, 1), (self.blocks_head_0_0_0, 0))
        self.connect((self.bladeRF_source_0_0, 0), (self.blocks_head_0_1, 0))
        self.connect((self.blocks_complex_to_interleaved_short_0, 0), (self.blocks_file_sink_0, 0))
        self.connect((self.blocks_complex_to_interleaved_short_0_0, 0), (self.blocks_file_sink_0_0, 0))
        self.connect((self.blocks_complex_to_interleaved_short_0_0_0, 0), (self.blocks_file_sink_0_0_0, 0))
        self.connect((self.blocks_complex_to_interleaved_short_0_1, 0), (self.blocks_file_sink_0_1, 0))
        self.connect((self.blocks_head_0, 0), (self.blocks_multiply_const_vxx_0, 0))
        self.connect((self.blocks_head_0_0, 0), (self.blocks_multiply_const_vxx_0_0, 0))
        self.connect((self.blocks_head_0_0_0, 0), (self.blocks_multiply_const_vxx_0_0_0, 0))
        self.connect((self.blocks_head_0_1, 0), (self.blocks_multiply_const_vxx_0_1, 0))
        self.connect((self.blocks_multiply_const_vxx_0, 0), (self.blocks_complex_to_interleaved_short_0, 0))
        self.connect((self.blocks_multiply_const_vxx_0_0, 0), (self.blocks_complex_to_interleaved_short_0_0, 0))
        self.connect((self.blocks_multiply_const_vxx_0_0_0, 0), (self.blocks_complex_to_interleaved_short_0_0_0, 0))
        self.connect((self.blocks_multiply_const_vxx_0_1, 0), (self.blocks_complex_to_interleaved_short_0_1, 0))


    def get_bandwidth(self):
        return self.bandwidth

    def set_bandwidth(self, bandwidth):
        self.bandwidth = bandwidth
        self.bladeRF_source_0.set_bandwidth(self.bandwidth, 0)
        self.bladeRF_source_0_0.set_bandwidth(self.bandwidth, 0)

    def get_gain4(self):
        return self.gain4

    def set_gain4(self, gain4):
        self.gain4 = gain4
        self.bladeRF_source_0.set_gain(self.gain4, 0)
        self.bladeRF_source_0.set_gain(self.gain4, 1)
        self.bladeRF_source_0_0.set_gain(self.gain4, 0)
        self.bladeRF_source_0_0.set_gain(self.gain4, 1)

    def get_nosamples(self):
        return self.nosamples

    def set_nosamples(self, nosamples):
        self.nosamples = nosamples
        self.blocks_head_0.set_length(self.nosamples)
        self.blocks_head_0_0.set_length(self.nosamples)
        self.blocks_head_0_0_0.set_length(self.nosamples)
        self.blocks_head_0_1.set_length(self.nosamples)

    def get_sps(self):
        return self.sps

    def set_sps(self, sps):
        self.sps = sps
        self.bladeRF_source_0.set_sample_rate(self.sps)
        self.bladeRF_source_0_0.set_sample_rate(self.sps)

    def get_tuning(self):
        return self.tuning

    def set_tuning(self, tuning):
        self.tuning = tuning
        self.bladeRF_source_0.set_center_freq(self.tuning, 0)
        self.bladeRF_source_0_0.set_center_freq(self.tuning, 0)



def argument_parser():
    parser = ArgumentParser()
    parser.add_argument(
        "--bandwidth", dest="bandwidth", type=eng_float, default=eng_notation.num_to_str(float(2000000)),
        help="Set Bandwidth LP [default=%(default)r]")
    parser.add_argument(
        "--gain4", dest="gain4", type=eng_float, default=eng_notation.num_to_str(float((-1))),
        help="Set Gain [default=%(default)r]")
    parser.add_argument(
        "--nosamples", dest="nosamples", type=intx, default=50000000,
        help="Set Liczba probek [default=%(default)r]")
    parser.add_argument(
        "--sps", dest="sps", type=eng_float, default=eng_notation.num_to_str(float(10000000)),
        help="Set Sample Rate [default=%(default)r]")
    parser.add_argument(
        "--tuning", dest="tuning", type=intx, default=868000000,
        help="Set Frequency [default=%(default)r]")
    return parser


def main(top_block_cls=nuand2sync, options=None):
    if options is None:
        options = argument_parser().parse_args()
    tb = top_block_cls(bandwidth=options.bandwidth, gain4=options.gain4, nosamples=options.nosamples, sps=options.sps, tuning=options.tuning)

    def sig_handler(sig=None, frame=None):
        tb.stop()
        tb.wait()

        sys.exit(0)

    signal.signal(signal.SIGINT, sig_handler)
    signal.signal(signal.SIGTERM, sig_handler)

    tb.start()
    tb.flowgraph_started.set()

    tb.wait()


if __name__ == '__main__':
    main()

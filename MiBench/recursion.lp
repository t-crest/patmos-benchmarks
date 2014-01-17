abort:
{}
{
  Xraise                <= 1 
  Xabort                <= 1
  X__call_exitprocs     <= 1
  WXexit                <= 1
  WX__init              <= 1
  WX__fini              <= 1
}
{};

xlate_word:
{}
{ 
  Xxlate_word <= 3300
  Xxlate_string <= 3300
  Xxlate_cardinal <= 2
}
{
};

print_path:
{}
{
  Xprint_path <= 100
}
{};

insertR:
{}
{
  XinsertR <= 450
}
{};

ntbl_bitcnt:
{}
{
  Xntbl_bitcnt <= 8
}
{};

qsort:
{}
{
  Xqsort <= 50000
}
{};

free_pool:
{}
{
  Xfree_pool               <= 1
  Xself_destruct           <= 1
  Xalloc_barray            <= 1
  Xalloc_large             <= 1
  Xalloc_small             <= 1
  Xalloc_sarray            <= 1
  Xjpeg_open_backing_store <= 1
  Xrealize_virt_arrays     <= 1
  Xjpeg_destroy            <= 1
  Xerror_exit              <= 1

  Xself_destruct + Xrealize_virt_arrays - Xerror_exit <= 1
  Xself_destruct + Xjpeg_open_backing_store - Xerror_exit <= 1
}
{};

finish_pass_master:
{}
{
  Xfinish_pass_master      <= 1
  Xpass_startup            <= 1
  Xprepare_for_pass        <= 1

  Xfinish_pass_master + Xpass_startup + Xprepare_for_pass = 1
}
{};

preload_image:
{}
{
  Xpreload_image11         <= 1
  Xpreload_image           <= 1

  Xpreload_image + Xpreload_image11 = 1
}
{};

start_input_pass292:
{}
{
  Xstart_input_pass292             <= 1
  Xreset_input_controller          <= 1
  Xfinish_output_pass              <= 1
  Xprepare_for_output_pass         <= 1

  Xstart_input_pass292 + Xreset_input_controller + Xfinish_output_pass + Xprepare_for_output_pass <= 1
}
{};

post_process_prepass:
{}
{
  Xpost_process_prepass    <= 1
  Xpost_process_1pass      <= 1

  Xpost_process_prepass + Xpost_process_1pass <= 1
}
{};

start_input_pass127:
{}
{
  Xstart_input_pass127             <= 1 
  Xreset_input_controller          <= 1

  Xstart_input_pass127 + Xreset_input_controller <= 1
}
{};

get_app14:
{}
{
  Xget_app14                       <= 1
  Xget_app0                        <= 1
  Xskip_variable                   <= 1
  Xjpeg_resync_to_restart          <= 1
  Xread_restart_marker             <= 1
  Xget_sof                         <= 1
  Xnext_marker                     <= 1
  Xread_markers                    <= 1
  Xconsume_markers                 <= 1
  Xdecode_mcu_AC_refine            <= 1
  Xdecode_mcu_DC_refine            <= 1
  Xdecode_mcu_AC_first             <= 1
  Xdecode_mcu_DC_first             <= 1
  Xjpeg_huff_decode                <= 1
  Xjpeg_fill_bit_buffer            <= 1
  Xdecode_mcu                      <= 1
  Xconsume_data                    <= 1
  XCOM_handler                     <= 1

  Xdecode_mcu_AC_refine + Xdecode_mcu_DC_refine + Xdecode_mcu_AC_first + Xdecode_mcu_DC_first <= 1
  Xread_markers + Xread_restart_marker + Xskip_variable + Xget_app0 + Xget_app14 <= 1
}
{};

finish_pass_master:
{}
{
  Xfinish_pass_master      <= 1
  Xpass_startup            <= 1
  Xprepare_for_pass        <= 1

  Xfinish_pass_master + Xpass_startup + Xprepare_for_pass <= 1
}
{};

PredictorVSetField:
{}
{
  XPredictorVSetField           <= 1
  XPredictorVGetField           <= 1
  XLogLuvVSetField              <= 1
  XLogLuvVGetField              <= 1
  XFax3VSetField                <= 1
  XFax3VGetField                <= 1
  XTIFFInitCCITTRLEW            <= 1
  XTIFFInitCCITTRLE             <= 1
  XTIFFInitCCITTFax4            <= 1
  XTIFFSetField                 <= 1
  XInitCCITTFax3                <= 1
  XTIFFInitCCITTFax3            <= 1
  XTIFFSetCompressionScheme     <= 1
  X_TIFFVSetField               <= 1

  XTIFFInitCCITTRLEW + XTIFFInitCCITTRLE + XTIFFInitCCITTFax4 + XTIFFInitCCITTFax3 <= 1

  set + get <= 1

  XPredictorVSetField - set <= 0
  XLogLuvVSetField    - set <= 0
  XFax3VSetField      - set <= 0
  XTIFFSetField       - set <= 0
  X_TIFFVSetField     - set <= 0

  XPredictorVGetField - get <= 0
  XLogLuvVGetField    - get <= 0
  XFax3VGetField      - get <= 0
}
{
  set
  get
};

PredictorSetupEncode:
{}
{
  XPredictorSetupEncode <= 1
  XPredictorSetupDecode <= 1

  XPredictorSetupEncode + XPredictorSetupDecode <= 1
}
{};

PredictorDecodeTile:
{}
{
  decode + encode <= 1

  XPredictorDecodeTile + XPredictorDecodeRow + XLogLuvDecodeTile + XLogLuvDecodeStrip - decode <= 0
  XPredictorEncodeTile + XPredictorEncodeRow + XLogLuvEncodeTile + XLogLuvEncodeStrip - encode <= 0
}
{
  decode
  encode
};

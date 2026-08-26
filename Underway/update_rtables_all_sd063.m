for d=194:220
   load_daily_nav(d,2026)
   append_daily_nav(d,2026)
   load_daily_bathy(d,2026)
   edit_daily_bathy(d,2026)
   append_daily_bathy(d,2026)
   load_daily_ocl(d,2026)
   %dy158_edit_ocl(d,2026);
   %plot_daily_ocl(d,2026)
   append_daily_ocl(d,2026)
end
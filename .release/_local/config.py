class Config:
    def __init__(self):
        self.verbose = False
        self.super_verbose = False
        self.local_mode = False
        self.skip_copying = False
        self.skip_zip = False
        self.skip_external_repos = False
        self.skip_localization = False
        self.only_localization = False
        self.use_unix_line_endings = False
        self.overwrite_existing = False
        self.nolib = False
        self.multi_game_types = False
        self.curseforge_id = None
        self.wowinterface_id = None
        self.wago_addons_id = None
        self.release_directory = None
        self.top_directory = None
        self.game_version = None
        self.pkgmeta_file = None
        self.package_name_label = None

    def update_from_args(self, args):
        self.verbose = args.v
        self.super_verbose = args.V
        self.local_mode = args.D
        self.skip_copying = args.c
        self.skip_zip = args.z
        self.skip_external_repos = args.e
        self.skip_localization = args.l
        self.only_localization = args.L
        self.use_unix_line_endings = args.u
        self.overwrite_existing = args.o
        self.nolib = args.s
        self.multi_game_types = args.S
        self.curseforge_id = args.p
        self.wowinterface_id = args.w
        self.wago_addons_id = args.a
        self.release_directory = args.r
        self.top_directory = args.t
        self.game_version = args.g
        self.pkgmeta_file = args.m
        self.package_name_label = args.n

    def __str__(self):
        return (
            f"Config(verbose={self.verbose}, super_verbose={self.super_verbose}, local_mode={self.local_mode},"
            f"skip_copying={self.skip_copying}, skip_zip={self.skip_zip}, "
            f"skip_external_repos={self.skip_external_repos}, skip_localization={self.skip_localization}, "
            f"only_localization={self.only_localization}, use_unix_line_endings={self.use_unix_line_endings}, "
            f"overwrite_existing={self.overwrite_existing}, nolib={self.nolib}, "
            f"multi_game_types={self.multi_game_types}, curseforge_id={self.curseforge_id}, "
            f"wowinterface_id={self.wowinterface_id}, wago_addons_id={self.wago_addons_id}, "
            f"release_directory={self.release_directory}, top_directory={self.top_directory}, "
            f"game_version={self.game_version}, pkgmeta_file={self.pkgmeta_file}, "
            f"package_name_label={self.package_name_label})"
        )


config = Config()

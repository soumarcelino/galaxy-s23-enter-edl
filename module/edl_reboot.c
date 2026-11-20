// SPDX-License-Identifier: GPL-2.0-only
#include <linux/module.h>
#include <linux/reboot.h>
#include <linux/string.h>
#include <linux/types.h>

enum qcom_download_mode {
	QCOM_DOWNLOAD_NODUMP = 0x00,
	QCOM_DOWNLOAD_EDL = 0x01,
};

extern void qcom_scm_set_download_mode(enum qcom_download_mode mode,
				       phys_addr_t tcsr_boot_misc);
extern int qcom_scm_get_download_mode(unsigned int *mode,
				      phys_addr_t tcsr_boot_misc);

static int edl_reboot_call(struct notifier_block *nb, unsigned long event,
			   void *data)
{
	const char *command = data;
	unsigned int mode = 0xff;

	if (event != SYS_RESTART || !command || strcmp(command, "edl"))
		return NOTIFY_DONE;

	qcom_scm_set_download_mode(QCOM_DOWNLOAD_EDL, 0);
	reboot_mode = REBOOT_WARM;
	qcom_scm_get_download_mode(&mode, 0);
	pr_info("edl_reboot: EDL requested, TZ mode = 0x%x\n", mode);
	return NOTIFY_OK;
}

static struct notifier_block edl_notifier = {
	.notifier_call = edl_reboot_call,
	.priority = INT_MIN,
};

static int __init edl_reboot_init(void)
{
	unsigned int mode = 0xff;
	int result = qcom_scm_get_download_mode(&mode, 0);

	pr_info("edl_reboot: loaded, current mode = 0x%x (result %d)\n",
		mode, result);
	return register_reboot_notifier(&edl_notifier);
}

static void __exit edl_reboot_exit(void)
{
	unregister_reboot_notifier(&edl_notifier);
}

module_init(edl_reboot_init);
module_exit(edl_reboot_exit);

MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("Restore reboot-to-EDL on the Samsung Galaxy S23 Ultra");

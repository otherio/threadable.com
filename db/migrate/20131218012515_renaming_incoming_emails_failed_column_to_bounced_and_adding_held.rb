class RenamingIncomingEmailsFailedColumnToBouncedAndAddingHeld < ActiveRecord::Migration
  def change
    rename_column "incoming_emails", "failed", "bounced"
    add_column    "incoming_emails", "held",   "boolean", default: false
  end
end

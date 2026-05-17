from django.db import migrations, models
import django.db.models.deletion
import django.utils.timezone
import apps.notification.models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        ('authentication', '0001_initial'),
        ('order', '0001_initial'),
    ]

    operations = [
        migrations.CreateModel(
            name='NotificationMessages',
            fields=[
                ('message_id', models.TextField(primary_key=True, serialize=False, default=apps.notification.models._uuid_str)),
                ('subject', models.TextField(blank=True, null=True)),
                ('body', models.TextField(blank=True, null=True)),
                ('delivery_channel', models.TextField(choices=[('EMAIL', 'EMAIL'), ('SMS', 'SMS'), ('IN_APP', 'IN_APP'), ('WHATSAPP', 'WHATSAPP')])),
                ('delivery_status', models.TextField(choices=[('PENDING', 'PENDING'), ('SENT', 'SENT'), ('FAILED', 'FAILED'), ('DELIVERED', 'DELIVERED')])),
                ('created_at', models.DateTimeField(default=django.utils.timezone.now)),
                ('sent_at', models.DateTimeField(blank=True, null=True)),
                ('account', models.ForeignKey(db_column='account_id', on_delete=django.db.models.deletion.CASCADE, to='authentication.accounts')),
                ('order', models.ForeignKey(blank=True, db_column='order_id', null=True, on_delete=django.db.models.deletion.SET_NULL, to='order.orders')),
            ],
            options={
                'db_table': 'notification_messages',
                'indexes': [
                    models.Index(fields=['account'], name='notif_accoun_0f6e8d_idx'),
                    models.Index(fields=['delivery_status', 'created_at'], name='notif_deliver_0e1b76_idx'),
                ],
            },
        ),
    ]

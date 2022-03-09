import { Component, OnInit } from '@angular/core';
import { FaIconLibrary } from '@fortawesome/angular-fontawesome';
import { faArrowRight, faHome, faShoppingBag, faTruck, IconPrefix } from '@fortawesome/free-solid-svg-icons';
import { Notification, NotificationService } from '../services/notification.service';

@Component({
  selector: 'app-notifications',
  templateUrl: './notifications.component.html',
  styleUrls: ['./notifications.component.scss']
})
export class NotificationsComponent implements OnInit {

  notifications:Notification[] = [];

  iconPrefix: IconPrefix = 'fas';
  faArrowRight = faArrowRight;

  constructor(
    private notificationService: NotificationService,
    private library: FaIconLibrary
  ) 
  { 
    library.addIcons(faShoppingBag, faTruck, faHome);
    notificationService.getNotifications().subscribe({
      next: data => {
        this.notifications = [...data];
      }
    })
  }

  ngOnInit(): void {
  }

}

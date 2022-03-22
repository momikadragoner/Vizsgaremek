import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { FaIconLibrary } from '@fortawesome/angular-fontawesome';
import { faArrowRight, faBell, faHome, faShoppingBag, faTruck, IconPrefix } from '@fortawesome/free-solid-svg-icons';
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
  faBell = faBell;

  constructor(
    private notificationService: NotificationService,
    private library: FaIconLibrary,
    private router: Router
  )
  {
    library.addIcons(faShoppingBag, faTruck, faHome);
    notificationService.getNotifications().subscribe({
      next: data => {
        this.notifications = [...data];
      }
    })
  }

  open(id:number){
    this.notificationService.updateNotification(this.notifications.filter(x => x.notificationId == id)[0]).subscribe();
    this.router.navigate([this.notifications.filter(x => x.notificationId == id)[0].link]);
  }

  ngOnInit(): void {
  }

}

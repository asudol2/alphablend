#include "alphaBlend.h"

#include <gtk/gtk.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>


FILE *fpointer_1, *fpointer_2;
char *fname;
unsigned int breadth, height, bmp_size, offset;
void *img, *img_2, *whole_img_1, *whole_img_2;

GtkWidget* GUI; 
GtkWidget* picture;
GtkWidget* box;
GtkBuilder* builder;



static gboolean on_click (GtkWidget *box, GdkEventButton *event, gpointer data) {
    int x = (int)event->x;
    int y = height - (int)event->y;

    alpha_blend(img, img_2, breadth, height, x, y);

    fpointer_1 = fopen(fname, "wb");
    fwrite(whole_img_1, 1, bmp_size, fpointer_1);
    fclose(fpointer_1);
    
    gtk_image_set_from_file(picture, fname);

    return FALSE;
};


// clears the buffor and close GUI
void close_gui() {
    free(whole_img_1);
    free(whole_img_2);

    gtk_main_quit();
};


int main(int argc, char *argv[]) {
    
    // error handling
    if (argc != 3) {
        printf("Require 2 files");
        return 0;
    }
    fpointer_1 = fopen(argv[1], "rb");
    fpointer_2 = fopen(argv[2], "rb");
    if (fpointer_1 == NULL || fpointer_2 == NULL) {
        printf("File cannot be found.\n");
        return 0;
    }

    fname = malloc(strlen(argv[1])+1);
    strcpy(fname, argv[1]);


    // read bmp sizes
    fseek(fpointer_1, 18, SEEK_SET);
    fread(&breadth, 4, 1, fpointer_1);
    fread(&height, 4, 1, fpointer_1);

    unsigned int width_2, height_2;
    fseek(fpointer_2, 18, SEEK_SET);
    fread(&width_2, 4, 1, fpointer_2);
    fread(&height_2, 4, 1, fpointer_2);

    if(breadth != width_2 || height != height_2){
        printf("Size of images must be same. ");
    };

    // calc params
    fseek(fpointer_1, 2, SEEK_SET);
    fread(&bmp_size, 4, 1, fpointer_1);
    fseek(fpointer_1, 10, SEEK_SET);
    fread(&offset, 4, 1, fpointer_1);

    unsigned int bmpSize_2, offset_2;
    fseek(fpointer_2, 2, SEEK_SET);
    fread(&bmpSize_2, 4, 1, fpointer_2);
    fseek(fpointer_2, 10, SEEK_SET);
    fread(&offset_2, 4, 1, fpointer_2);


    whole_img_1 = malloc(bmp_size);
    img = whole_img_1 + offset;
    whole_img_2 = malloc(bmpSize_2);
    img_2 = whole_img_2 + offset_2;

    fseek(fpointer_1, 0, SEEK_SET);
    fread(whole_img_1, 1, bmp_size, fpointer_1);
    fclose(fpointer_1);
    fseek(fpointer_2, 0, SEEK_SET);
    fread(whole_img_2, 1, bmpSize_2, fpointer_2);
    fclose(fpointer_2);

    gtk_init(&argc, &argv);
    builder = gtk_builder_new();

    gtk_builder_add_from_file(builder, "window.glade", NULL);

    GUI = GTK_WIDGET(gtk_builder_get_object(builder, "window"));
    gtk_builder_connect_signals(builder, NULL);
    box = GTK_WIDGET(gtk_builder_get_object(builder, "event_box"));

    picture = GTK_WIDGET(gtk_builder_get_object(builder, "image"));

    gtk_image_set_from_file(picture, argv[1]);

    g_signal_connect (G_OBJECT (box), "button_press_event", G_CALLBACK (on_click), picture);
    g_signal_connect(G_OBJECT(GUI), "destroy", close_gui, NULL);


    g_object_unref(builder);
    gtk_widget_show(GUI);
    gtk_main();

    return 0;
}

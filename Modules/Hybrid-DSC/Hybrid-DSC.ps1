  WindowStartupLocation = 'CenterScreen' >
        <Window
                                                      xmlns = 'http://schemas.microsoft.com/winfx/2006/xaml/presentation'
                                                    xmlns:x = 'http://schemas.microsoft.com/winfx/2006/xaml'
                                                      Width = '350'
                                                      Height = '200'
                                        HorizontalAlignment = 'Center'
                                                    Topmost = 'True' 
                                                       Icon = 'C:\Users\Administrator\Documents\WindowsPowerShell\Modules\Hybrid-DSC\Graphics\icon.ico'
                                    
                <Grid>
                    <Grid.RowDefinitions>
                        <RowDefinition Height = '3*' />
                        <RowDefinition Height = '*' />
                    </Grid.RowDefinitions>
                    <Grid Grid.Row = '0' >
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width = '*' />
                            <ColumnDefinition Width = '2*' />
                        </Grid.ColumnDefinitions>
                        <Grid.RowDefinitions>
                            <RowDefinition Height = '*' />
                            <RowDefinition Height = '*' />
                            <RowDefinition Height = '*' />
                        </Grid.RowDefinitions>
                        <TextBlock Grid.Column = '0' Grid.Row = '0' Margin = '10' VerticalAlignment = 'Center' HorizontalAlignment = 'Right' >
                            Controller Name:</TextBlock>
                        <Label Name = 'DC' Grid.Column = '1' Grid.Row = '0' VerticalAlignment = 'Center' Height = '24' Margin = '10' />
                        <TextBlock Grid.Column = '0' Grid.Row = '1' Margin = '10' VerticalAlignment = 'Center' HorizontalAlignment = 'Right' >
                            DNS Name:</TextBlock>
                        <Label Name = 'Domain' Grid.Column = '1' Grid.Row = '1' VerticalAlignment = 'Center' Height = '24' Margin = '10' />
                        <TextBlock Grid.Column = '0' Grid.Row = '2' Margin = '10' VerticalAlignment = 'Center' HorizontalAlignment = 'Right' >
                            NetBIOS Name:</TextBlock>
                        <Label Name = 'NetBIOS' Grid.Column = '1' Grid.Row = '2' VerticalAlignment = 'Center' Height = '24' Margin = '10' />
                    </Grid>
                    <Grid Grid.Row = '1' >
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width = '*' />
                            <ColumnDefinition Width = '*' />
                        </Grid.ColumnDefinitions>
                        <Button Name = 'Ok' Content = 'Ok' Grid.Column = '0' Grid.Row = '1' Margin = '10' />
                        <Button Name = 'Cancel' Content = 'Cancel' Grid.Column = '1' Grid.Row = '1' Margin = '10' />
                    </Grid>
                </Grid>
            </Window>
